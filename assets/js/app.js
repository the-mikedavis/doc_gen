import css from '../css/app.sass'
import 'phoenix_html'
import { Elm } from '../src/Main.elm'

const live_tags = document.getElementById('live-tags')
if (live_tags)
  Elm.Main.init({node: live_tags})
