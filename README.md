SnapShot Extractor!
===================

This is a tool for [Evercam](http://evercam.io/) specifically build to extract images for a camera while using an existing endpoint in [Evercam-media  (an API for talking to cameras)](https://github.com/evercam/evercam-media) .

**Core Dependencies**

 1. Dropbox (For uploading image)
 2. Httpoison (Http requests)
 3. Mailgun (Email sending)
 4. Quantum (Cron Job)

**How it works**


It takes the most recent created `SnapshotExtractor` whom status is `0` at the moment.

 1. It will update its status to `1` and send en email to the owner that image extraction has been started with Extraction information.
 2. It will fetch total days and recording dates from `SnapshotExtractor`'s `schedule`.
   e.g `{"Monday":["12:30-13:0"],"Tuesday":[],"Wednesday":["4:0-4:30"],"Thursday":[],"Friday":["8:30-9:0"],"Saturday":[],"Sunday":["19:30-20:0"]}`
 3. From a specific starting to ending date, for each day and according to schedule, It will fetch all images and save them to DropBox.
 4. No crash on any timeout/Any other reason from `evercam-media` or `dropbox`.
 5. After complition it will send an email again with total image gained / total image expected.
