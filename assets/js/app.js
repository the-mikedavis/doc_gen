import tailcss from '../css/tail.css'
import css from '../css/app.sass'
import 'phoenix_html'
import {LiveTags} from '../src/LiveTags.elm'
import {Dashboard} from '../src/Dashboard.elm'
import {Player} from '../src/Player.elm'
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
      let [checkmark] = chooseTags[i].getElementsByTagName('i')
      const oldClassName = input.checked ? 'bg-blue' : 'bg-blue-darker'
      const newClassName = input.checked ? 'bg-blue-darker' : 'bg-blue'
      chooseTags[i].classList.remove(oldClassName)
      chooseTags[i].classList.add(newClassName)
      if (checkmark.classList.contains('active'))
        checkmark.classList.remove('active')
      else
        checkmark.classList.add('active')
      input.checked = !input.checked
    })
}

const checkTags = document.getElementsByClassName('tag-choose')
const generateButton = document.getElementById('generate-movie')
if (checkTags) {
  for (let i = 0; i < checkTags.length; i++) {
    checkTags[i].addEventListener('click', handleCheckTag)
  }
}

function handleCheckTag () {
  const checked = document.querySelectorAll('input[type=checkbox]:checked')
  if (checked.length == 0) {
    generateButton.disabled = true
    generateButton.classList.add('disabled')
  } else {
    generateButton.disabled = false
    generateButton.classList.remove('disabled')
  }
}

const dashboard = document.getElementById('dashboard')
if (dashboard)
  Dashboard.embed(dashboard, {uri: buildSocketUri(), token: window.phxCsrfToken})

const player = document.getElementById('player')
if (player) {
  const app = Player.embed(player, {videos: window.video_ids})
  window.addEventListener('load', function () {
    const videoElem = document.getElementById('theater')

    app.ports.playVideo.subscribe(function () {
      setTimeout(() => {
        videoElem.load()
        videoElem.play()
      }, 100)
    })

    videoElem.addEventListener('ended', function () {
      app.ports.videoEnded.send(true)
    })
  })
}

const theater = document.getElementById('theater')
if (theater) {
  theater.addEventListener('ended', () => startNextVideo(thumbs));
  const thumbs = document.getElementsByClassName('theater-thumb-holster')
  for (let i = 0; i < thumbs.length; i++)
    thumbs[i].addEventListener('click', function () {
      const [img] = thumbs[i].children
      const index = img.id.slice(-1)
      forceVideo(index, thumbs)
    })
}

const drop_zone = document.getElementById('video_video_file')
const file_input_label = document.getElementById('upload-text')
if (drop_zone)
  drop_listen(drop_zone, file_input_label)

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

window.fireProgressBar = function (event) {
  const progressBarHolder = document.getElementById('progress-bar-holder')
  const progressBar = document.getElementById('progress-bar')
  progressBarHolder.classList.add('active')

  let width = 0
  let interval = setInterval(frame, 10)

  function frame() {
    if (width >= 100)
      clearInterval(interval)
    else
      progressBar.style.width = (++width) + '%'
  }
}

const progressBarTriggers = document.getElementsByClassName('progress-trigger')
for (let i = 0; i < progressBarTriggers.length; i++)
  progressBarTriggers[i].addEventListener('click', window.fireProgressBar)
