function reload() {
  fetch("/")
    .then((response) => {
      return response.text();
    })
    .then((html) => {
      document.body.innerHTML = html;
      console.log("Reloaded");
    });
}

function pollServer() {
  fetch("http://localhost:12345/")
    .then(() => {
      reload();
      pollServer();
    })
    .catch((err) => {
      console.log(err);
      console.log("Server not ready. Reload the page with the server running.");
    });
}

pollServer();
