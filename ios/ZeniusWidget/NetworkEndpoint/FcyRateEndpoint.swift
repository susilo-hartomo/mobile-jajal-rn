import Foundation

extension Endpoint {
  static func foreignExchangeRates(
    appId: String = "9f317b0b-1c01-431e-851c-337cb78612ec",
    clientKey: String = "f71aff73-c964-4faa-a57d-f34dfccd4b77",
    cookie: String = "eca5e44671b4a880fbb5e63a7bac4413=623f4c9e64b0a968bf78f69ec4cb0607; 7b16504097a8e9089c04bcad3ca06d74=937e0b79b0dce5df5c0906b1d0b39221; 7abd20a612df91724f4ef769de99f8e4=576576db790447206b7ecf4f0fb21399; 1e9b02705a2a58c36370b7c5d306fabc=2838fe179828e9979721007d8085edf8; 44494615fbe9dedebf9b5d3489a7e39d=a37a732002001d93921ddd146e9f09bd; 96d40dc0c6d988d6b27ebb567432a07b=8a57c493d328cec0d1c3c43c21b43f6d; AWSALB=SrMxoSi7Hmc%2FbpGT0E4IBIHzVFHHkfRykNCUz44q8XJqirbODBQs9m5AzcyCtLyl6kuylfhYMB0tuggubeF%2BNjfWyPtbujvQHDts55c7iufo%2F%2BbJOi%2BLVQSrrjuj; AWSALBCORS=SrMxoSi7Hmc%2FbpGT0E4IBIHzVFHHkfRykNCUz44q8XJqirbODBQs9m5AzcyCtLyl6kuylfhYMB0tuggubeF%2BNjfWyPtbujvQHDts55c7iufo%2F%2BbJOi%2BLVQSrrjuj; AWSALBTG=l%2BvhuFKv7QHt7MkAtnKeRun8cIgYQ7E844%2Fx%2B58etGh4pl07pxanirpuYaBkY0Jm3sJxdG8jfFfiBprf3mRTJyAY1b0WISNkHdbRXJrk7%2BPDlex6ka43kE2xVWeif10GcLCcPfRe%2FPELUX9VMZ4kSh88Q1xQnK68842Bx7030Qty; AWSALBTGCORS=l%2BvhuFKv7QHt7MkAtnKeRun8cIgYQ7E844%2Fx%2B58etGh4pl07pxanirpuYaBkY0Jm3sJxdG8jfFfiBprf3mRTJyAY1b0WISNkHdbRXJrk7%2BPDlex6ka43kE2xVWeif10GcLCcPfRe%2FPELUX9VMZ4kSh88Q1xQnK68842Bx7030Qty; cd48a0f6cfef2226b69302a157639a15=694537ffbb69a4a8dd7dedff280ae6e9; f284da379bc4a90f15ec5f143b9f4b1b=98b411acba953cf2be21551e37ebabc0"
  ) -> Endpoint {
    var headers: [String: String] = [
      "Accept": "application/json",
      "X-APP-ID": appId,
      "X-CLIENT-KEY": clientKey
    ]
    if !cookie.isEmpty {
      headers["Cookie"] = cookie
    }

    return Endpoint(
      path: "/jenius-widget/v1/foreign-exchanges/rates",
      method: .get,
      headers: headers
    )
  }
}
