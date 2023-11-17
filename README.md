# ONVIF-SSM
Use of source-specific multicast (SSM) with ONVIF conformant cameras

## Background
Video can either be unicast (one source to one receiver) or multicast (one source to many receivers). There are also two types of multicast: any-source and source-specific. Source-specific multicast has advantages in respect of being simpler to implement in the transmission network and being less susceptible to malicious attacks.

ONVIF mandate use of the real-time streaming protocol (RTSP) for video streaming. From the ONVIF Streaming Specification Version 23.06:
> 5.2.2.1 All devices and clients shall support RTSP ([RFC 2326]) for session initiation and playback control. RTSP shall use TCP as its transport protocol, the default TCP port for RTSP traffic is 554. The Session Description Protocol (SDP) shall be used to provide media stream information and SDP shall conform to [RFC 4566]

The RFCs referenced by ONVIF cover unicast and any-source multicast. Source-specific multicast is covered by [RFC 3569: An Overview of Source-Specific Multicast (SSM)](https://www.rfc-editor.org/rfc/rfc3569), [RFC 4570: Session Description Protocol (SDP) Source Filters](https://www.rfc-editor.org/rfc/rfc4570), [RFC 4604: Using Internet Group Management Protocol Version 3 (IGMPv3) and Multicast Listener Discovery Protocol Version 2 (MLDv2) for Source-Specific Multicast](https://www.rfc-editor.org/rfc/rfc4604) and [RFC 4607: Source-Specific Multicast for IP](https://www.rfc-editor.org/rfc/rfc4607). There doesn't seem to be any reference to these RFCs in the ONVIF specifications. So we cannot rely on ONVIF to guarantee support for source-specific multicast.

There is one reference to the need for a source-filter line in the [ONVIF Real Time Streaming Device Test Specification](https://www.onvif.org/profiles/conformance/device-test-2/) in appendix A.8.

Can we therefore rely on the IETF standards instead? A review of the RFCs indicates that they specify the methods for supporting source-specific multicast, but do not mandate how the video source (e.g. camera) must implement it. It appears to be left to the camera manufacturer to achieve this. Testing in a source-specific network has shown ONVIF cameras responding to RTSP requests with SDP information that does not contain the source-specific information detailed in RFC 4570.

Outside of ONVIF, camera suppliers appear to support source-specific multicast by using dedicated URLs for the RTSP video stream. This has been seen with cameras from Axis and Bosch. This implementation does not carry across to the implementation of ONVIF in the cameras. Presumably because the ONVIF GetStreamUri command has no facility to request a source-specific multicast stream.

An alternative to RTSP is for the camera to permanently multicast and for video clients to use RTP to join the existing multicast streams. This method is mentioned briefly in the [ONVIF Media Service Specification](https://www.onvif.org/specs/srv/media/ONVIF-Media-Service-Spec.pdf) in section 5.17 Multicast. The complication here is that most video client software applications are unable to make RTP joins and decode H.264 video streams using in-band SPS/PPS information and therefore require an SDP file. So whilst it is possible to avoid using RTSP, another method is required to generate the appropriate SDP information and share it with video clients.

## Process to generate SSM video SDP information
The following describes a process to generate SDP files that enable open-source video clients to perform an RTP IGMPv3 join to an existing multicast video channel without the source (camera or encoder) fully supporting SSM.

The steps involved are:
1. Obtain device {VideoStreamUri}, {MulticastAddress} and {MulticastPortNumber}.
1. Extract {SourceAddress} from the {VideoStreamUri}.
1. Authenticate with the ONVIF device (using credentials for RTSP streaming where authentication has been enabled).
1. Issue RTSP DESCRIBE and capture the returned SDP information.
1. Extract from the SDP information the "a=rtpmap" line and store as {rtpmap}.
1. Extract from the SDP information the "a=fmtp" line (contains sprop parameter set details) and store as {fmtp}.
1. Extract from {rtpmap} the payload format number (e.g., 35, 96, etc.) and store as {PayloadFormat}.

Generate the following new SDP information:
>v=0  
>o=- 0 0 IN IP4 {SourceAddress}  
>s=SSM SDP  
>c=IN IP4 {MulticastAddress}  
>a=source-filter: incl IN IP4 * {SourceAddress}  
>m=video {MulticastPortNumber} RTP/AVP {PayloadFormat}  
>{rtpmap}  
>{fmtp}  

Using an SDP file containing this information has been successfully tested using both VLC and ffplay to RTP join video from ONVIF conformant cameras and video encoders from various manufaturers over a source-specific multicast network.

Note: The above SDP allows only the video channel to be joined. Any audio and data channels are ignored.
