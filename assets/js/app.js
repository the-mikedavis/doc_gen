import css from '../css/app.sass'
import 'phoenix_html'
import {LiveTags} from '../src/LiveTags.elm'
import {Dashboard} from '../src/Dashboard.elm'
// import videojs from '../node_modules/video.js'

const live_tags = document.getElementById('live-tags')
if (live_tags)
  LiveTags.embed(live_tags, buildSocketUri())

const dashboard = document.getElementById('dashboard')
if (dashboard)
  Dashboard.embed(dashboard, buildSocketUri())

    /*
const video_source = document.getElementById('video-source')
if (video_source) {
  var video = videojs('play').ready(function() {
    this.on('ended', function() {
      video_source.src = '/stream/' + window.video_ids.shift()
    })
  })
}
*/

function buildSocketUri() {
  return window.location.host + "/socket/websocket?token=" + window.userToken
}

window.submitIfValid = function() {
  let [form] = document.getElementsByTagName('form')
  if (form.reportValidity())
    form.submit()
  return false;
}
