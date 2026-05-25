import SwiftUI
import MapKit

/// UIKit-backed Map view that supports route polyline overlays.
/// Used because SwiftUI's Map in iOS 16 doesn't natively support polyline overlays.
struct EvacuationMapView: UIViewRepresentable {
    
    let userCoordinate: CLLocationCoordinate2D?
    let shelters: [Shelter]
    let selectedShelter: Shelter?
    let alerts: [DisasterAlert]
    let primaryRoute: MKRoute?
    let alternativeRoutes: [MKRoute]
    let isEmergencyMode: Bool
    
    var onShelterTapped: ((Shelter) -> Void)?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.mapType = .standard
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        context.coordinator.parent = self
        
        // Remove old overlays and annotations (except user location)
        mapView.removeOverlays(mapView.overlays)
        let nonUserAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
        mapView.removeAnnotations(nonUserAnnotations)
        
        // Add shelter annotations
        for shelter in shelters {
            let annotation = ShelterAnnotation(shelter: shelter, isSelected: shelter.id == selectedShelter?.id)
            mapView.addAnnotation(annotation)
        }
        
        // Add disaster alert annotations
        for alert in alerts {
            let annotation = DisasterAlertAnnotation(alert: alert)
            mapView.addAnnotation(annotation)
            
            // Add danger zone circle overlay in emergency mode
            if isEmergencyMode {
                let radiusMeters: CLLocationDistance = alert.severity == .critical ? 50_000 : 25_000
                let circle = MKCircle(center: alert.coordinate, radius: radiusMeters)
                mapView.addOverlay(circle)
            }
        }
        
        // Add alternative route overlays (gray, drawn first so they're behind primary)
        for route in alternativeRoutes {
            let polyline = route.polyline
            polyline.title = "alternative"
            mapView.addOverlay(polyline, level: .aboveRoads)
        }
        
        // Add primary route overlay (blue, drawn last so it's on top)
        if let primaryRoute = primaryRoute {
            let polyline = primaryRoute.polyline
            polyline.title = "primary"
            mapView.addOverlay(polyline, level: .aboveRoads)
        }
        
        // Fit map to show content
        adjustRegion(mapView)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    // MARK: - Region
    
    private func adjustRegion(_ mapView: MKMapView) {
        if let route = primaryRoute {
            let rect = route.polyline.boundingMapRect
            let insets = UIEdgeInsets(top: 80, left: 40, bottom: 200, right: 40)
            mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
        } else if let userCoord = userCoordinate {
            let region = MKCoordinateRegion(
                center: userCoord,
                span: MKCoordinateSpan(
                    latitudeDelta: AppConstants.defaultMapSpanDelta,
                    longitudeDelta: AppConstants.defaultMapSpanDelta
                )
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Coordinator
    
    final class Coordinator: NSObject, MKMapViewDelegate {
        var parent: EvacuationMapView
        
        init(parent: EvacuationMapView) {
            self.parent = parent
        }
        
        // Polyline & circle rendering
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                if polyline.title == "primary" {
                    renderer.strokeColor = UIColor(SafePathColors.accentBlue)
                    renderer.lineWidth = 6
                } else {
                    renderer.strokeColor = UIColor.systemGray3
                    renderer.lineWidth = 4
                    renderer.lineDashPattern = [8, 6]
                }
                return renderer
            }
            
            if let circle = overlay as? MKCircle {
                let renderer = MKCircleRenderer(circle: circle)
                renderer.fillColor = UIColor(SafePathColors.dangerRed).withAlphaComponent(0.10)
                renderer.strokeColor = UIColor(SafePathColors.dangerRed).withAlphaComponent(0.40)
                renderer.lineWidth = 2
                return renderer
            }
            
            return MKOverlayRenderer(overlay: overlay)
        }
        
        // Annotation views
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation { return nil }
            
            if let shelterAnn = annotation as? ShelterAnnotation {
                return shelterAnnotationView(for: shelterAnn, in: mapView)
            }
            
            if let alertAnn = annotation as? DisasterAlertAnnotation {
                return alertAnnotationView(for: alertAnn, in: mapView)
            }
            
            return nil
        }
        
        private func shelterAnnotationView(for annotation: ShelterAnnotation, in mapView: MKMapView) -> MKAnnotationView {
            let id = "ShelterPin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            
            view.annotation = annotation
            view.glyphImage = UIImage(systemName: "building.2.fill")
            view.displayPriority = .required
            view.canShowCallout = true
            
            if annotation.isSelected {
                view.markerTintColor = UIColor(SafePathColors.accentBlue)
            } else {
                switch annotation.shelter.status {
                case .available:
                    view.markerTintColor = UIColor(SafePathColors.safeGreen)
                case .almostFull:
                    view.markerTintColor = UIColor(SafePathColors.warningOrange)
                case .full, .closed, .unsafe:
                    view.markerTintColor = UIColor(SafePathColors.dangerRed)
                }
            }
            
            let btn = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = btn
            
            return view
        }
        
        private func alertAnnotationView(for annotation: DisasterAlertAnnotation, in mapView: MKMapView) -> MKAnnotationView {
            let id = "AlertPin"
            let view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKMarkerAnnotationView
                ?? MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: id)
            
            view.annotation = annotation
            view.glyphImage = UIImage(systemName: "exclamationmark.triangle.fill")
            view.markerTintColor = UIColor(SafePathColors.dangerRed)
            view.displayPriority = .required
            view.canShowCallout = true
            
            return view
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            if let shelterAnn = view.annotation as? ShelterAnnotation {
                parent.onShelterTapped?(shelterAnn.shelter)
            }
        }
    }
}

// MARK: - Custom Annotation Classes

final class ShelterAnnotation: NSObject, MKAnnotation {
    let shelter: Shelter
    let isSelected: Bool
    
    var coordinate: CLLocationCoordinate2D { shelter.coordinate }
    var title: String? { shelter.name }
    var subtitle: String? {
        "\(shelter.status.displayName) • \(shelter.availableSpace) spots"
    }
    
    init(shelter: Shelter, isSelected: Bool) {
        self.shelter = shelter
        self.isSelected = isSelected
    }
}

final class DisasterAlertAnnotation: NSObject, MKAnnotation {
    let alert: DisasterAlert
    
    var coordinate: CLLocationCoordinate2D { alert.coordinate }
    var title: String? { alert.typeDisplayName }
    var subtitle: String? {
        "M\(String(format: "%.1f", alert.magnitude)) • \(alert.severity.displayName)"
    }
    
    init(alert: DisasterAlert) {
        self.alert = alert
    }
}
