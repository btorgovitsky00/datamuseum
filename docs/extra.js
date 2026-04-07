document.addEventListener("DOMContentLoaded", function() {
  // Open external links in new tab
  var links = document.querySelectorAll("a[href^='http']");
  links.forEach(function(link) {
    if (!link.href.includes("btorgovitsky00.github.io")) {
      link.setAttribute("target", "_blank");
      link.setAttribute("rel", "noopener noreferrer");
    }
  });

  // Ames Lab logo
  var amesLink = document.querySelector("a[href='https://cherylames.com']");
  if (amesLink) {
    amesLink.innerHTML = "<img src='" + window.location.origin + "/datamuseum/reference/figures/ames_logo.jpeg' height='24' alt='Ames Lab'/>";
  }
});
