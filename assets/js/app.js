// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import { TremorxHooks } from "tremorx";

import Uploaders from "./uploaders";

let Hooks = {};

Hooks = {
  ...TremorxHooks,
};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  uploaders: Uploaders,
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

window.addEventListener("phx:remove-el", (e) =>
  document.getElementById(e.detail.id).remove()
);

//Custom notifier
window.addEventListener("phx:notify", async (e) => {
  show_notification(e.detail.title, e.detail.message, e.detail.type);
});

function show_notification(title, message, type) {
  let element = document.getElementById("notifications");

  element?.classList.add(
    "space-y-2",
    "transition-all",
    "duration-800",
    "ease-in"
  );

  const node = build_notification(
    title,
    message,
    element,
    String(type).toLowerCase()
  );

  element?.insertBefore(node, element?.firstChild);

  enter(node, {
    enter: ["transition-all", "duration-500", "ease-in-out"],
    enterFrom: ["-translate-y-4", "opacity-0", "h-0"],
    enterTo: ["translate-y-0", "opacity-100", "h-full"],
  });
}

function build_notification(title, message, parent, type) {
  const successIcon = `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-6 h-6">
      <path fill-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zm13.36-1.814a.75.75 0 10-1.22-.872l-3.236 4.53L9.53 12.22a.75.75 0 00-1.06 1.06l2.25 2.25a.75.75 0 001.14-.094l3.75-5.25z" clip-rule="evenodd" />
    </svg>`;
  const errorIcon = `
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-6 h-6">
      <path fill-rule="evenodd" d="M2.25 12c0-5.385 4.365-9.75 9.75-9.75s9.75 4.365 9.75 9.75-4.365 9.75-9.75 9.75S2.25 17.385 2.25 12zM12 8.25a.75.75 0 01.75.75v3.75a.75.75 0 01-1.5 0V9a.75.75 0 01.75-.75zm0 8.25a.75.75 0 100-1.5.75.75 0 000 1.5z" clip-rule="evenodd" />
    </svg>`;

  const node = document.createElement("div");
  const id = Math.random();
  node.classList.add("relative", "w-80", "hidden", "notification", "flex");

  const iconNode = document.createElement("div");
  iconNode.classList.add(
    "px-1",
    "py-1",
    type == "success" ? "text-green-500" : "text-red-500"
  );

  if (type == "success") {
    iconNode.innerHTML = successIcon;
  } else {
    iconNode.innerHTML = errorIcon;
  }

  node.appendChild(iconNode);
  const contentNode = document.createElement("div");

  contentNode.classList.add("flex-1", "px-2");
  const titleNode = document.createElement("h4");
  const titleTextnode = document.createTextNode(title);
  titleNode.classList.add("text-gray-800", "font-semibold");
  titleNode.appendChild(titleTextnode);

  const messageNode = document.createElement("p");
  messageNode.classList.add("text-sm", "text-gray-600");
  const textnode = document.createTextNode(message);
  messageNode.appendChild(textnode);

  contentNode.append(titleNode);
  contentNode.append(messageNode);
  node.appendChild(contentNode);

  const close = document.createElement("button");
  const closeIcon = `<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5">
      <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
    </svg>
    `;

  close.classList.add(
    "absolute",
    "top-2",
    "right-2",
    "cursor-pointer",
    "notifcation-close-icon"
  );
  close.innerHTML = closeIcon;
  close.id = id;
  close.addEventListener("click", async (_) => {
    await leave(node, {
      leave: ["transition-all", "duration-300", "ease-out"],
      leaveFrom: ["translate-y-0", "opacity-100", "h-full"],
      leaveTo: ["-translate-y-4", "opacity-0", "h-0"],
    });

    try {
      parent?.removeChild(node);
    } catch (error) {}
  });
  node.appendChild(close);

  setTimeout(async () => {
    await leave(node, {
      leave: ["transition-all", "duration-300", "ease-out"],
      leaveFrom: ["translate-y-0", "opacity-100", "h-full"],
      leaveTo: ["-translate-y-4", "opacity-0", "h-0"],
    });

    try {
      parent?.removeChild(node);
    } catch (error) {}
  }, 8000);

  return node;
}

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
