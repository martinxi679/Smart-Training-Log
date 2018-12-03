//
//  SMLRestfulAPI.swift
//  Smart Training Log
//

import Foundation

class SMLRestfulAPI {

    let session = URLSession.shared

    static var common: SMLRestfulAPI {
        return (try? Container.resolve(SMLRestfulAPI.self)) ?? SMLRestfulAPI()
    }

    struct Endpoint {
        static let root = "https://us-central1-smart-training-log-2a77d.cloudfunctions.net"

        static let addTreatment = root + "/" + "addTreatmentNotification"
        static let inviteuser = root + "/" + "inviteUser"
        static let treatmentCheckin = root + "/" + "treatmentCheckinNotification"

        static func url(for url: String) -> URL? {
            return URL(string: url)
        }
    }
}

extension SMLRestfulAPI {

    func sendAddTreatmentNotification(userHashID: String, treatmentID: String, uid: String) {

        guard let url = Endpoint.url(for: Endpoint.addTreatment) else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "uid": uid,
            "tid": treatmentID,
            "uHashID": userHashID
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload) else {
            return
        }

        request.httpBody = data

        session.dataTask(with: request).resume()
    }

    func sendUserCheckinNotification(userHashID: String, treatmentID: String, name: String) {

        guard let url = Endpoint.url(for: Endpoint.treatmentCheckin) else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        //request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "uname": name,
            "tid": treatmentID,
            "uHashID": userHashID
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload) else {
            return
        }

        request.httpBody = data

        session.dataTask(with: request).resume()
    }

    func inviteUserEmail(userEmail: String, team: String) {

        guard let url = Endpoint.url(for: Endpoint.inviteuser) else { return }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload: [String: Any] = [
            "userEmail": userEmail,
            "team": team
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: payload) else { return }

        request.httpBody = data

        session.dataTask(with: request).resume()
    }
}
