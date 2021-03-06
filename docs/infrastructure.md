# Infrastucture Document

This document is a sketch of the information flow and technologies being used or proposed for use in the rtER project.

## System Structure

                   ----------------------------       ---------------
                   | Immersive Command Center |       | ISAS System |
                   |                          |       |             |
                   ----------------------------       ---------------
             (selected media/content) |  (2)           (3) | (I/O user content: sound files)
                                      |                    |
    -------------------    (1)     -------------------------------------   (4)   --------------------------
    | VOST Web Client | ---------  | rtER Server | Geospatial User     | ------- | Video Streaming Server |
    |                 | (content)  |             | Meta-Content Server | (URIs)  |                        |
    -------------------            -------------------------------------         --------------------------
                |                           | (5)       (meta-data) | (6)       (7) | (video stream)    |
                |                           |                       |               |                   |
                |                           |                      -------------------                  |
                |                           ---------------------- | rtER Mobile App |                  |
                |                                                  |                 |                  |
                |                                                  -------------------                  |
                -----------------------------------------------------------------------------------------

## Details and Technologies

### Immersive Command Center
CAVE environment with top down projected maps and immersive street view (developped for round 1). Includes various visualized/spatialized data.

* Queries for most relevant and highly ranked data from the rtER server via (2).
* (2) not currently implemented like uses HTTP/GET with xml/json. Queries returned include URIs for content.

### VOST Web Client
Collaborative application for VOST volunteers (developped for round 2). Shows user content which can be collaboratively manipulated discussed and promoted.

 * Queries for new content over (1) via HTTP/GET usually via AJAX, data returned as JSON with URI references to content.
 * Submit content ranking via (1) HTTP/GET, usually AJAX, data JSON.
 * Submit new content via HTTP/POST, mime-multipart for images.
 * Submit other content manipulation via (1) again HTTP/POST via AJAX with JSON.


### rtER Server / Spatialized User Meta-Content Server
Generic system the "Spatialized User Meta-Content Server" used to store content submitted by users which is tagged with spatial data. Availble via API to submit, retrieve and modify this data.

Some special tools and feature for the VOST Web client (such as servicing AJAX request for grid layout). Also some special tools for the rtER Mobile App such handling the interactive heading adjustements between VOST and field users.

 * (1) Content queries and VOST content
 * (2) ....
 * (3) ISAS will use our system for user submitted spatialized audio clips.
 * (5) Desired heading information relayed from VOST volunteers.
 * (6) Heading and location information from phone. Video stream information.
 * (7) Video stream.

### rtER Mobile App
Mobile application to stream video. Allows users to be directed where to film by VOST from the VOST Mobile App.

* (5) Desired heading information relayed from VOST volunteers.
* (6) Heading and location information from phone. Video stream information.
* (7) Video stream.

### Video Stream Server

I imagine we could integrate video into the VOST web app in two ways: thumbnail preview and full video. Plus, we could have the video displayed live (at lowest possible latency) and on-demand (after capture and with VCR control).

* live video thumbnails as preview widgets (auto-updating image widgets that periodically fetches new low resolution thumbs from the distribution server)
* live video player (instant playback of live video feeds without pause/rewind/replay functions, much like a video conference)
* on-demand video thumbnails (image widgets to quickly skim through a recorded video at low resolution without fully downloading it)
* on-demand video player (cached playback of recorded video feeds with pause/rewind/replay functions)

Technically I'm not yet confident both types of players can be merged easily, so I keep them separate until I know more.

The video server would split a live stream originating at a mobile device and prepare it for distribution to potentially many VOST web app clients. This allows us to integrate transformations, record the video feeds, scale the distribution side, integrate video analysis and adapt the live feeds to different situations.

#### Server Integration

The video part should remain as generic as possible and not constrain the rest of the system architecture nor should it require any complex interaction patterns in the backend (since this will not scale! and breaks REST principles). I suggest the following integration direction:

* let the rtER mobile app submit a video feed upload request to the rtER server
* let the rtER server respond with a video upload token (to be detailed)
* let the rtER mobile app contact the video ingest point and stream its video independently
* the ingest point can independently verify the token, receive and process the video feed
* serve the VOST Web Clients with URIs (or tokens) pointing to video/thumb distribution servers
* let VOST Web Clients fetch video/thumb data independently


#### Ingest side (streaming a live video feed from the rtER mobile app)

* direct upload from mobile to server would work via any of the protocols like HTTP PUT, WebSocket, RTP over HTTP
* quick and robust solution for prototype development is HTTP PUT of chunked self-containing video segments (~1-2sec would be good for live video)
* upload URI should be provided via outside signalling
* server must be reachable on a public IP address
* format-wise we may have no choice than sticking to hardware accelerated encoders provided by device vendors
* H264 for video and AAC for audio would be ideal (low bandwidth, reasonable browser support, transcoding may be unnecessary)


#### Server-side Processing

* transcode video into distribution format (ideally we should do without re-encoding, but maybe repackaging is necessary depending on the distribution protocol)
* store video segments on disc for distribution to live and on-demand players
* periodically generate video thumbnail images (one per video segment, that is, one every 1-2 sec)


#### Distribution side (towards VOST Web Clients)

No matter what we do we will have to use a special 'live' video player since browsers lack native support. Ideas on how to get video to the VOST Web Client are

* HTTP GET
  * use standard webserver to host video segments and thumbnails
  * update the HTML5 video tag's source for each segment, double buffer video tags and start/stop them in turns
  * would let the browser automatically fetch video data
  * very hacky solution, playback may be jerky, but it's a simple option to try
* DASH ([Dynamic Adaptive Streaming over HTTP](http://www.bogotobogo.com/VideoStreaming/mpeg_dash.php))
  * could use standard webserver and normal download of video segments (once stored by ingest server)
  * requires DASH support in browsers (native or as JS library)
  * buffering and fetching logic would be already integrated with the DASH client
  * requires a particular stream description (must be generated by video server)
  * introduces a conceptual latency of ~2.5 * segment duration (~1-2 sec)
* WebSockets
  * directly deliver video segments over a WebSocket between server and browser
  * requires custom server implementation
  * requires custom buffering and fetching logic at client-side
  * use MediaSource API to feed video to a browser's HTML5 video tag
  * avoids extra latency introduced by waiting on disc storage of segments


#### Video Issues

* we need to define how our user interface should deal with live video and VCR functionality (rewind, replay)
* video and audio codec/format [support](https://developer.mozilla.org/en-US/docs/HTML/Supported_media_formats) differs between browsers, so transcoding is required to reach all browsers
* WebSocket is not the normal way of getting video into browsers, but for live feeds there is no common standard yet
* DASH is not widely used yet, but browsers (Chrome, Firefox) have prototype implementations since 2012

## RESTful API

### Collections and Items

* Roles (attributes)
	* Title
	* Permissions
* User (attributes)
	* Username
	* Password/Salt
	* Role
	* Trust Level
	* Created Time
* User Direction (child of User)
	* User
	* LockUser ID
	* Command
	* Heading/Lat/Lng
	* Update Time	
* Item (attributes)
	* ID
	* Type
		* Video
		* Image
		* Twitter
			* Single tweets
			* Twitter search
		* News/Web page
		* Text element
		* Audio (ISAS)
	* Authoer ID
	* URI (content)
	* URI (thumbnail)
	* URI (upload)
	* Has heading/has location
	* Lat/Lng/Heading
	* Live
	* Start Time
	* Stop Time
* Comments (child of item) (attributes)
	* ID
	* Item UID
	* Author
	* Text
	* Time
* Taxonomy 
	* Term
	* Automated
	* Author
	* Time Created
* Shared Ranking (child of Taxonomy)
	* Term
	* Timestamp
	* Ranking (N item reference list)
* Taxonomy Relationship
	* Term
	* ItemID

### Resources

* /roles/?query GET _get all or filtered by query, return found as JSON_
* /roles/ POST _create role, send JSON return role as JSON_
* /roles/:title/ GET _get particular user, return user as JSON_
* /roles/:title/ PUT _update role, send JSON return updated role as JSON_
* /roles/:title/ DELETE _delete role, return Status No Content 204_
------
* /users/?query GET _get all users or filtered by query, return found users as JSON_
* /users/ POST _create user, send JSON return user as JSON_
* /users/:id/ GET _get particular user, return user as JSON_
* /users/:id/ PUT _update user, send JSON return updated user as JSON_
* /users/:id/ DELETE _delete user, return Status No Content 204_
------
* Created and Deleted along with user
* /users/:id/direction/ GET _get current user direction and LOCK, return as JSON_
* /users/:id/direction/ PUT _set direction and lock, return JSON, maybe return error if lock unavailable_
------
* /items/?query GET _get all items or filtered by query, return found items as JSON_
* /items/ POST _create item, send JSON return item JSON_
* /items/:id/ GET _get particular item, return item as JSON_
* /items/:id/ PUT _update item, send JSON return item as JSON_
* /items/:id/ DELETE _delete item, return Status No Content 204_
------
* /items/:id/comments/ GET _get all comments as JSON_
* /items/:id/comments/ POST _create comment for item with :id, return comment as JSON_ 
* /items/:id/comments/:id/ GET _get comment, JSON_
* /items/:id/comments/:id/ PUT _update comment, return updated comment as JSON_
 * /items/:id/comments/:id/ DELETE _delete comment, return Status No Content 204_
------
* /taxonomy/?query GET _get all terms or filtered by query, return found terms as JSON_
* /taxonomy/ POST _create term, send JSON return term as JSON_
* /taxonomy/:term/ GET _get particular term, returned as JSON_
* /taxonomy/:term/ PUT _update term, send JSON get updated term as JSON_
* /taxonomy/:term/ DELETE _delete term, return Status No Content 204_
------
* Created and Deleted along with taxonomy term
* /taxonomy/:term/ranking/ GET _get ranking for :term as JSON_
* /taxonomy/:term/ranking/ PUT _update ranking for :term, send JSON, return updated JSON ranking_
------