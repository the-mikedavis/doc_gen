import tailcss from '../css/tail.css'
import css from '../css/app.sass'
import 'phoenix_html'
import {LiveTags} from '../src/LiveTags.elm'
import {Dashboard} from '../src/Dashboard.elm'
import drop_listen from './drop_zone'

const live_tags = document.getElementById('live-tags')
if (live_tags) {
  if (window.videoId)
    LiveTags.embed(live_tags, {uri: buildSocketUri(), id: window.videoId})
  else
    LiveTags.embed(live_tags, {uri: buildSocketUri(), id: -1})
}

const chooseTags = document.getElementsByClassName('tag-choose')
if (chooseTags) {
  for (let i = 0; i < chooseTags.length; i++)
    chooseTags[i].addEventListener('click', function () {
      let [input] = chooseTags[i].getElementsByTagName('input')
      const oldClassName = input.checked ? 'bg-blue' : 'bg-blue-darker'
      const newClassName = input.checked ? 'bg-blue-darker' : 'bg-blue'
      chooseTags[i].classList.remove(oldClassName)
      chooseTags[i].classList.add(newClassName)
      input.checked = !input.checked
    })
}

const dashboard = document.getElementById('dashboard')
if (dashboard)
  Dashboard.embed(dashboard, {uri: buildSocketUri(), token: window.phxCsrfToken})

const theater = document.getElementById('theater')
if (theater) {
  theater.addEventListener('ended', startNextVideo);
}

const drop_zone = document.getElementById('video_video_file')
const file_input_label = document.getElementById('upload-text')
if (drop_zone)
  drop_listen(drop_zone, file_input_label)

let videoCounter = 1;
function startNextVideo() {
  if (videoCounter >= window.video_ids.length) {
    window.location.pathname = '/'
  } else {
    theater.pause()
    const [source] = theater.getElementsByTagName('source')
    source.setAttribute('src', '/stream/' + window.video_ids[videoCounter++])
    theater.load()
    theater.play()
  }
}

function buildSocketUri() {
  const protocol = location.protocol == 'https:' ? 'wss://' : 'ws://'
  return protocol + window.location.host + "/socket/websocket?token=" + window.userToken
}

window.submitIfValid = function() {
  let [form] = document.getElementsByTagName('form')
  if (form.reportValidity())
    form.submit()
  return false;
}

window.animateThumb = function (event) {
  event.target.setAttribute('src', event.target.src.replace('jpeg', 'gif'))
}

window.stillThumb = function (event) {
  event.target.setAttribute('src', event.target.src.replace('gif', 'jpeg'))
}
