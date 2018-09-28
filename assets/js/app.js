import css from '../css/app.sass'
import '../elm/src/main.css'
import 'phoenix_html'
import Elm from '../elm/src/Main.elm'

const live_tags = document.getElementById('live-tags')
if (live_tags)
  Elm.Main.embed(live_tags)
