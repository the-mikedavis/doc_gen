import css from '../css/app.sass'
import 'phoenix_html'
import {LiveTags} from '../src/LiveTags.elm'

const live_tags = document.getElementById('live-tags')
if (live_tags)
  LiveTags.embed(live_tags)
