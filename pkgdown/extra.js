document.addEventListener("DOMContentLoaded", function() {
  var amesLink = document.querySelector("a[href='https://cherylames.com']");
  if (amesLink) {
    amesLink.innerHTML = "<img src='" + window.location.origin + "/datamuseum/reference/figures/ames_logo.jpeg' height='24' alt='Ames Lab'/>";
  }
});
