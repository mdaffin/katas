# Natas

http://overthewire.org/wargames/natas/

## Solutions
natas0:natas0
natas1:gtVrDuiDfck831PqWsLEZy5gyDz1clto
natas2:ZluruAthQk7Q2MqmDeTiUij2ZvWy2mBi
natas3:sJIJNW6ucpu6HPZ1ZAchaDtwd7oGrD14
natas4:Z9tkRkWmpt9Qr7XrR5jWRkgOU901swEZ

## Notes

### Level 1

Password is a comment in the source =>
view-source:http://natas0.natas.labs.overthewire.org/

### Level 2

Same as above, right clicking is meant to be blocked but is not on firefox at
least => view-source:http://natas1.natas.labs.overthewire.org/

### Level 3

There was a image pixel on the page with the location `files/pixel.png`. No
robots.txt so the only place the start stabbing around is `/files/` which has a
directory listing and exposes two files, including a `users.txt`. =>
http://natas2.natas.labs.overthewire.org/files/users.txt. This contains the
password for nates3.

### Level 4

Hint in the source was to try Google =>
`site:http://natas3.natas.labs.overthewire.org/`. Site search on Google reveals
two links, one to a directory listing on the site with the `users.txt` =>
http://natas3.natas.labs.overthewire.org/s3cr3t/users.txt. Even without the
hint the robots.txt gives away the secret.

### Level 5

Looks to be enforcing on refeerer, but we know that can be faked. This can be
changed in the network tab to the referrer that is given on the site, sending
the request does not reload the page but you can see the page in the response
for that request, the password is on the page. This could also be gotten with
curl. Infact a lot of these could be gotten with curl... hmmm, I think we can
automate these.

