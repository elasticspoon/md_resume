const regex = /<meta property="time_built" content="([^"]+)">/;
let lastModified;

async function startReload() {
  setInterval(() => {
    if (!lastModified) {
      setLastModified();
      reload();
      // console.log("Initial reload");
      return;
    } else {
      // console.log("Checking for reload");
      reloadIfOld();
    }
  }, 1000);
}

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

function reloadIfOld() {
  getBuiltTime().then((timeBuilt) => {
    // console.log("Last modified: " + lastModified);
    if (timeBuilt > lastModified) {
      // console.log("Reloading because of new build");
      reload();
      lastModified = timeBuilt;
    }
  });
}

function setLastModified() {
  getBuiltTime().then((timeBuilt) => {
    lastModified = timeBuilt;
  });
}

async function getBuiltTime() {
  let inputString = await fetch("/");
  let text = await inputString.text();
  let match = text.match(regex);
  if (match && match[1]) {
    const timeBuiltString = match[1];
    return new Date(timeBuiltString);
  }
}

startReload();
