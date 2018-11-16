function listen(file_input, label) {
  file_input.addEventListener('change', function () {
    if (file_input.files.length > 0) {
      label.innerHTML = file_input.files[0].name;
    } else {
      label.innerHTML = 'Upload'
    }
  })
}

export default listen;
