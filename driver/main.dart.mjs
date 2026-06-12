// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `load-ids` option is passed. Each load ID maps to one
  //   or more wasm files as specified in the emitted JSON file. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It also takes a callback that should be invoked with the
  //   loaded module in a format supported by `WebAssembly.compile` or
  //   `WebAssembly.compileStreaming` and the result of using the JS 'import'
  //   API on the js file path. It should return a Promise that resolves when
  //   all the modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports,
      {loadDeferredModules, loadDynamicModule, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _1: (decoder, codeUnits) => decoder.decode(codeUnits),
      _2: () => new TextDecoder("utf-8", {fatal: true}),
      _3: () => new TextDecoder("utf-8", {fatal: false}),
      _4: (s) => +s,
      _5: x0 => new Uint8Array(x0),
      _6: (x0,x1,x2) => x0.set(x1,x2),
      _7: (x0,x1) => x0.transferFromImageBitmap(x1),
      _9: (x0,x1,x2) => x0.slice(x1,x2),
      _10: (x0,x1) => x0.decode(x1),
      _11: (x0,x1) => x0.segment(x1),
      _12: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _135: (x0,x1) => x0.appendChild(x1),
      _166: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _167: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _168: (x0,x1) => new OffscreenCanvas(x0,x1),
      _169: x0 => x0.remove(),
      _170: (x0,x1) => x0.append(x1),
      _172: x0 => x0.unlock(),
      _173: x0 => x0.getReader(),
      _174: (x0,x1) => x0.item(x1),
      _175: x0 => x0.next(),
      _176: x0 => x0.now(),
      _177: (x0,x1) => x0.revokeObjectURL(x1),
      _178: x0 => x0.close(),
      _179: (x0,x1,x2,x3,x4) => ({type: x0,data: x1,premultiplyAlpha: x2,colorSpaceConversion: x3,preferAnimation: x4}),
      _180: x0 => new window.ImageDecoder(x0),
      _181: (x0,x1) => ({frameIndex: x0,completeFramesOnly: x1}),
      _182: (x0,x1) => x0.decode(x1),
      _183: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._183(f,arguments.length,x0) }),
      _184: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _186: (x0,x1) => x0.getModifierState(x1),
      _187: x0 => x0.preventDefault(),
      _188: x0 => x0.stopPropagation(),
      _189: (x0,x1) => x0.removeProperty(x1),
      _190: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._190(f,arguments.length,x0) }),
      _191: x0 => new window.FinalizationRegistry(x0),
      _192: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _194: (x0,x1) => x0.unregister(x1),
      _195: (x0,x1) => x0.prepend(x1),
      _196: x0 => new Intl.Locale(x0),
      _197: (x0,x1) => x0.observe(x1),
      _198: x0 => x0.disconnect(),
      _199: (x0,x1) => x0.getAttribute(x1),
      _200: (x0,x1) => x0.contains(x1),
      _201: (x0,x1) => x0.querySelector(x1),
      _202: (x0,x1) => x0.matchMedia(x1),
      _203: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._203(f,arguments.length,x0) }),
      _204: (x0,x1,x2) => x0.call(x1,x2),
      _205: x0 => x0.blur(),
      _206: x0 => x0.hasFocus(),
      _207: (x0,x1) => x0.removeAttribute(x1),
      _208: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _209: (x0,x1) => x0.hasAttribute(x1),
      _210: (x0,x1) => x0.getModifierState(x1),
      _211: (x0,x1) => x0.createTextNode(x1),
      _212: x0 => x0.getBoundingClientRect(),
      _213: (x0,x1) => x0.replaceWith(x1),
      _214: (x0,x1) => x0.contains(x1),
      _215: (x0,x1) => x0.closest(x1),
      _653: x0 => new Uint8Array(x0),
      _656: () => globalThis.window.flutterConfiguration,
      _658: x0 => x0.assetBase,
      _663: x0 => x0.canvasKitMaximumSurfaces,
      _664: x0 => x0.debugShowSemanticsNodes,
      _665: x0 => x0.hostElement,
      _666: x0 => x0.multiViewEnabled,
      _667: x0 => x0.nonce,
      _669: x0 => x0.fontFallbackBaseUrl,
      _679: x0 => x0.console,
      _680: x0 => x0.devicePixelRatio,
      _681: x0 => x0.document,
      _682: x0 => x0.history,
      _683: x0 => x0.innerHeight,
      _684: x0 => x0.innerWidth,
      _685: x0 => x0.location,
      _686: x0 => x0.navigator,
      _687: x0 => x0.visualViewport,
      _688: x0 => x0.performance,
      _689: x0 => x0.parent,
      _691: x0 => x0.URL,
      _693: (x0,x1) => x0.getComputedStyle(x1),
      _694: x0 => x0.screen,
      _695: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._695(f,arguments.length,x0) }),
      _696: (x0,x1) => x0.requestAnimationFrame(x1),
      _700: (x0,x1) => x0.warn(x1),
      _703: x0 => globalThis.parseFloat(x0),
      _704: () => globalThis.window,
      _705: () => globalThis.Intl,
      _706: () => globalThis.Symbol,
      _707: (x0,x1,x2,x3,x4) => globalThis.createImageBitmap(x0,x1,x2,x3,x4),
      _709: x0 => x0.clipboard,
      _710: x0 => x0.maxTouchPoints,
      _711: x0 => x0.vendor,
      _712: x0 => x0.language,
      _713: x0 => x0.platform,
      _714: x0 => x0.userAgent,
      _715: (x0,x1) => x0.vibrate(x1),
      _716: x0 => x0.languages,
      _717: x0 => x0.documentElement,
      _718: (x0,x1) => x0.querySelector(x1),
      _719: (x0,x1) => x0.querySelectorAll(x1),
      _721: (x0,x1) => x0.createElement(x1),
      _724: (x0,x1) => x0.createEvent(x1),
      _725: x0 => x0.activeElement,
      _728: x0 => x0.head,
      _729: x0 => x0.body,
      _731: (x0,x1) => { x0.title = x1 },
      _734: x0 => x0.visibilityState,
      _735: () => globalThis.document,
      _736: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._736(f,arguments.length,x0) }),
      _737: (x0,x1) => x0.dispatchEvent(x1),
      _745: x0 => x0.target,
      _747: x0 => x0.timeStamp,
      _748: x0 => x0.type,
      _750: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _757: x0 => x0.firstChild,
      _761: x0 => x0.parentElement,
      _763: (x0,x1) => { x0.textContent = x1 },
      _764: x0 => x0.parentNode,
      _766: (x0,x1) => x0.removeChild(x1),
      _767: x0 => x0.isConnected,
      _775: x0 => x0.clientHeight,
      _776: x0 => x0.clientWidth,
      _777: x0 => x0.offsetHeight,
      _778: x0 => x0.offsetWidth,
      _779: x0 => x0.id,
      _780: (x0,x1) => { x0.id = x1 },
      _783: (x0,x1) => { x0.spellcheck = x1 },
      _784: x0 => x0.tagName,
      _785: x0 => x0.style,
      _787: (x0,x1) => x0.querySelectorAll(x1),
      _788: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _789: x0 => x0.tabIndex,
      _790: (x0,x1) => { x0.tabIndex = x1 },
      _791: (x0,x1) => x0.focus(x1),
      _792: x0 => x0.scrollTop,
      _793: (x0,x1) => { x0.scrollTop = x1 },
      _794: (x0,x1) => { x0.scrollLeft = x1 },
      _795: x0 => x0.scrollLeft,
      _796: x0 => x0.classList,
      _797: (x0,x1) => x0.scrollIntoView(x1),
      _800: (x0,x1) => { x0.className = x1 },
      _802: (x0,x1) => x0.getElementsByClassName(x1),
      _803: x0 => x0.click(),
      _804: (x0,x1) => x0.attachShadow(x1),
      _807: x0 => x0.computedStyleMap(),
      _808: (x0,x1) => x0.get(x1),
      _814: (x0,x1) => x0.getPropertyValue(x1),
      _815: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _816: x0 => x0.offsetLeft,
      _817: x0 => x0.offsetTop,
      _818: x0 => x0.offsetParent,
      _820: (x0,x1) => { x0.name = x1 },
      _821: x0 => x0.content,
      _822: (x0,x1) => { x0.content = x1 },
      _826: (x0,x1) => { x0.src = x1 },
      _827: x0 => x0.naturalWidth,
      _828: x0 => x0.naturalHeight,
      _832: (x0,x1) => { x0.crossOrigin = x1 },
      _834: (x0,x1) => { x0.decoding = x1 },
      _835: x0 => x0.decode(),
      _840: (x0,x1) => { x0.nonce = x1 },
      _845: (x0,x1) => { x0.width = x1 },
      _847: (x0,x1) => { x0.height = x1 },
      _850: (x0,x1) => x0.getContext(x1),
      _918: x0 => x0.width,
      _919: x0 => x0.height,
      _921: (x0,x1) => x0.fetch(x1),
      _922: x0 => x0.status,
      _924: x0 => x0.body,
      _925: x0 => x0.arrayBuffer(),
      _928: x0 => x0.read(),
      _929: x0 => x0.value,
      _930: x0 => x0.done,
      _937: x0 => x0.name,
      _938: x0 => x0.x,
      _939: x0 => x0.y,
      _942: x0 => x0.top,
      _943: x0 => x0.right,
      _944: x0 => x0.bottom,
      _945: x0 => x0.left,
      _955: x0 => x0.height,
      _956: x0 => x0.width,
      _957: x0 => x0.scale,
      _958: (x0,x1) => { x0.value = x1 },
      _961: (x0,x1) => { x0.placeholder = x1 },
      _963: (x0,x1) => { x0.name = x1 },
      _964: x0 => x0.selectionDirection,
      _965: x0 => x0.selectionStart,
      _966: x0 => x0.selectionEnd,
      _969: x0 => x0.value,
      _971: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _972: x0 => x0.readText(),
      _973: (x0,x1) => x0.writeText(x1),
      _975: x0 => x0.altKey,
      _976: x0 => x0.code,
      _977: x0 => x0.ctrlKey,
      _978: x0 => x0.key,
      _979: x0 => x0.keyCode,
      _980: x0 => x0.location,
      _981: x0 => x0.metaKey,
      _982: x0 => x0.repeat,
      _983: x0 => x0.shiftKey,
      _984: x0 => x0.isComposing,
      _986: x0 => x0.state,
      _987: (x0,x1) => x0.go(x1),
      _989: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _990: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _991: x0 => x0.pathname,
      _992: x0 => x0.search,
      _993: x0 => x0.hash,
      _997: x0 => x0.state,
      _1000: (x0,x1) => x0.createObjectURL(x1),
      _1002: x0 => new Blob(x0),
      _1012: x0 => x0.matches,
      _1016: x0 => x0.matches,
      _1020: x0 => x0.relatedTarget,
      _1022: x0 => x0.clientX,
      _1023: x0 => x0.clientY,
      _1024: x0 => x0.offsetX,
      _1025: x0 => x0.offsetY,
      _1028: x0 => x0.button,
      _1029: x0 => x0.buttons,
      _1030: x0 => x0.ctrlKey,
      _1034: x0 => x0.pointerId,
      _1035: x0 => x0.pointerType,
      _1036: x0 => x0.pressure,
      _1037: x0 => x0.tiltX,
      _1038: x0 => x0.tiltY,
      _1039: x0 => x0.getCoalescedEvents(),
      _1042: x0 => x0.deltaX,
      _1043: x0 => x0.deltaY,
      _1044: x0 => x0.wheelDeltaX,
      _1045: x0 => x0.wheelDeltaY,
      _1046: x0 => x0.deltaMode,
      _1053: x0 => x0.changedTouches,
      _1056: x0 => x0.clientX,
      _1057: x0 => x0.clientY,
      _1060: x0 => x0.data,
      _1063: (x0,x1) => { x0.disabled = x1 },
      _1065: (x0,x1) => { x0.type = x1 },
      _1066: (x0,x1) => { x0.max = x1 },
      _1067: (x0,x1) => { x0.min = x1 },
      _1068: x0 => x0.value,
      _1069: (x0,x1) => { x0.value = x1 },
      _1070: x0 => x0.disabled,
      _1071: (x0,x1) => { x0.disabled = x1 },
      _1073: (x0,x1) => { x0.placeholder = x1 },
      _1075: (x0,x1) => { x0.name = x1 },
      _1076: (x0,x1) => { x0.autocomplete = x1 },
      _1078: x0 => x0.selectionDirection,
      _1079: x0 => x0.selectionStart,
      _1081: x0 => x0.selectionEnd,
      _1084: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1085: (x0,x1) => x0.add(x1),
      _1087: (x0,x1) => { x0.noValidate = x1 },
      _1088: (x0,x1) => { x0.method = x1 },
      _1089: (x0,x1) => { x0.action = x1 },
      _1114: x0 => x0.orientation,
      _1115: x0 => x0.width,
      _1116: x0 => x0.height,
      _1117: (x0,x1) => x0.lock(x1),
      _1136: x0 => new ResizeObserver(x0),
      _1139: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1139(f,arguments.length,x0,x1) }),
      _1147: x0 => x0.length,
      _1148: x0 => x0.iterator,
      _1149: x0 => x0.Segmenter,
      _1150: x0 => x0.v8BreakIterator,
      _1151: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1154: x0 => x0.language,
      _1155: x0 => x0.script,
      _1156: x0 => x0.region,
      _1174: x0 => x0.done,
      _1175: x0 => x0.value,
      _1176: x0 => x0.index,
      _1180: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1181: (x0,x1) => x0.adoptText(x1),
      _1182: x0 => x0.first(),
      _1183: x0 => x0.next(),
      _1184: x0 => x0.current(),
      _1186: () => globalThis.window.FinalizationRegistry,
      _1197: x0 => x0.hostElement,
      _1198: x0 => x0.viewConstraints,
      _1201: x0 => x0.maxHeight,
      _1202: x0 => x0.maxWidth,
      _1203: x0 => x0.minHeight,
      _1204: x0 => x0.minWidth,
      _1205: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1205(f,arguments.length,x0) }),
      _1206: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1206(f,arguments.length,x0) }),
      _1207: (x0,x1) => ({addView: x0,removeView: x1}),
      _1210: x0 => x0.loader,
      _1211: () => globalThis._flutter,
      _1212: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1213: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1213(f,arguments.length,x0) }),
      _1214: (module,f) => finalizeWrapper(f, function() { return module.exports._1214(f,arguments.length) }),
      _1215: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1218: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1218(f,arguments.length,x0) }),
      _1219: x0 => ({runApp: x0}),
      _1221: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1221(f,arguments.length,x0,x1) }),
      _1222: x0 => new Promise(x0),
      _1223: x0 => x0.length,
      _1224: () => globalThis.window.ImageDecoder,
      _1225: x0 => x0.tracks,
      _1227: x0 => x0.completed,
      _1229: x0 => x0.image,
      _1235: x0 => x0.displayWidth,
      _1236: x0 => x0.displayHeight,
      _1237: x0 => x0.duration,
      _1240: x0 => x0.ready,
      _1241: x0 => x0.selectedTrack,
      _1242: x0 => x0.repetitionCount,
      _1243: x0 => x0.frameCount,
      _1292: x0 => x0.toArray(),
      _1293: x0 => x0.toUint8Array(),
      _1294: x0 => ({serverTimestamps: x0}),
      _1295: x0 => ({source: x0}),
      _1296: x0 => ({merge: x0}),
      _1298: x0 => new firebase_firestore.FieldPath(x0),
      _1299: (x0,x1) => new firebase_firestore.FieldPath(x0,x1),
      _1300: (x0,x1,x2) => new firebase_firestore.FieldPath(x0,x1,x2),
      _1301: (x0,x1,x2,x3) => new firebase_firestore.FieldPath(x0,x1,x2,x3),
      _1302: (x0,x1,x2,x3,x4) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4),
      _1303: (x0,x1,x2,x3,x4,x5) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5),
      _1304: (x0,x1,x2,x3,x4,x5,x6) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6),
      _1305: (x0,x1,x2,x3,x4,x5,x6,x7) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7),
      _1306: (x0,x1,x2,x3,x4,x5,x6,x7,x8) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8),
      _1307: (x0,x1,x2,x3,x4,x5,x6,x7,x8,x9) => new firebase_firestore.FieldPath(x0,x1,x2,x3,x4,x5,x6,x7,x8,x9),
      _1308: () => globalThis.firebase_firestore.documentId(),
      _1309: (x0,x1) => new firebase_firestore.GeoPoint(x0,x1),
      _1310: x0 => globalThis.firebase_firestore.vector(x0),
      _1311: x0 => globalThis.firebase_firestore.Bytes.fromUint8Array(x0),
      _1312: x0 => globalThis.firebase_firestore.writeBatch(x0),
      _1313: (x0,x1) => globalThis.firebase_firestore.collection(x0,x1),
      _1315: (x0,x1) => globalThis.firebase_firestore.doc(x0,x1),
      _1320: x0 => x0.call(),
      _1344: x0 => x0.commit(),
      _1346: (x0,x1,x2,x3) => x0.set(x1,x2,x3),
      _1347: (x0,x1,x2) => x0.set(x1,x2),
      _1348: (x0,x1,x2) => x0.update(x1,x2),
      _1349: x0 => globalThis.firebase_firestore.deleteDoc(x0),
      _1350: x0 => globalThis.firebase_firestore.getDoc(x0),
      _1351: x0 => globalThis.firebase_firestore.getDocFromServer(x0),
      _1352: x0 => globalThis.firebase_firestore.getDocFromCache(x0),
      _1353: (x0,x1) => ({includeMetadataChanges: x0,source: x1}),
      _1354: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1354(f,arguments.length,x0) }),
      _1355: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1355(f,arguments.length,x0) }),
      _1356: (x0,x1,x2,x3) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2,x3),
      _1357: (x0,x1,x2) => globalThis.firebase_firestore.onSnapshot(x0,x1,x2),
      _1359: (x0,x1) => globalThis.firebase_firestore.setDoc(x0,x1),
      _1360: (x0,x1) => globalThis.firebase_firestore.query(x0,x1),
      _1361: x0 => globalThis.firebase_firestore.getDocs(x0),
      _1362: x0 => globalThis.firebase_firestore.getDocsFromServer(x0),
      _1363: x0 => globalThis.firebase_firestore.getDocsFromCache(x0),
      _1364: x0 => globalThis.firebase_firestore.limit(x0),
      _1365: x0 => globalThis.firebase_firestore.limitToLast(x0),
      _1366: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1366(f,arguments.length,x0) }),
      _1367: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1367(f,arguments.length,x0) }),
      _1368: (x0,x1) => globalThis.firebase_firestore.orderBy(x0,x1),
      _1370: (x0,x1,x2) => globalThis.firebase_firestore.where(x0,x1,x2),
      _1373: x0 => globalThis.firebase_firestore.doc(x0),
      _1376: (x0,x1) => x0.data(x1),
      _1380: x0 => x0.docChanges(),
      _1389: () => globalThis.firebase_firestore.serverTimestamp(),
      _1390: x0 => globalThis.firebase_firestore.increment(x0),
      _1397: (x0,x1) => globalThis.firebase_firestore.getFirestore(x0,x1),
      _1399: x0 => globalThis.firebase_firestore.Timestamp.fromMillis(x0),
      _1400: (module,f) => finalizeWrapper(f, function() { return module.exports._1400(f,arguments.length) }),
      _1416: () => globalThis.firebase_firestore.updateDoc,
      _1417: () => globalThis.firebase_firestore.or,
      _1418: () => globalThis.firebase_firestore.and,
      _1423: x0 => x0.path,
      _1426: () => globalThis.firebase_firestore.GeoPoint,
      _1427: x0 => x0.latitude,
      _1428: x0 => x0.longitude,
      _1430: () => globalThis.firebase_firestore.VectorValue,
      _1431: () => globalThis.firebase_firestore.Bytes,
      _1434: x0 => x0.type,
      _1436: x0 => x0.doc,
      _1438: x0 => x0.oldIndex,
      _1440: x0 => x0.newIndex,
      _1442: () => globalThis.firebase_firestore.DocumentReference,
      _1446: x0 => x0.path,
      _1455: x0 => x0.metadata,
      _1456: x0 => x0.ref,
      _1461: x0 => x0.docs,
      _1463: x0 => x0.metadata,
      _1467: () => globalThis.firebase_firestore.Timestamp,
      _1468: x0 => x0.seconds,
      _1469: x0 => x0.nanoseconds,
      _1506: x0 => x0.hasPendingWrites,
      _1508: x0 => x0.fromCache,
      _1515: x0 => x0.source,
      _1520: () => globalThis.firebase_firestore.startAfter,
      _1521: () => globalThis.firebase_firestore.startAt,
      _1522: () => globalThis.firebase_firestore.endBefore,
      _1523: () => globalThis.firebase_firestore.endAt,
      _1542: (x0,x1) => x0.createElement(x1),
      _1549: (x0,x1,x2,x3) => x0.open(x1,x2,x3),
      _1553: (x0,x1) => globalThis.firebase_database.ref(x0,x1),
      _1560: (x0,x1) => globalThis.firebase_database.update(x0,x1),
      _1577: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1577(f,arguments.length,x0,x1) }),
      _1578: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1578(f,arguments.length,x0) }),
      _1579: (x0,x1,x2) => globalThis.firebase_database.onChildAdded(x0,x1,x2),
      _1580: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1580(f,arguments.length,x0,x1) }),
      _1581: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1581(f,arguments.length,x0) }),
      _1582: (x0,x1,x2) => globalThis.firebase_database.onValue(x0,x1,x2),
      _1583: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1583(f,arguments.length,x0,x1) }),
      _1584: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1584(f,arguments.length,x0) }),
      _1585: (x0,x1,x2) => globalThis.firebase_database.onChildRemoved(x0,x1,x2),
      _1586: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1586(f,arguments.length,x0,x1) }),
      _1587: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1587(f,arguments.length,x0) }),
      _1588: (x0,x1,x2) => globalThis.firebase_database.onChildChanged(x0,x1,x2),
      _1589: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1589(f,arguments.length,x0,x1) }),
      _1590: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1590(f,arguments.length,x0) }),
      _1591: (x0,x1,x2) => globalThis.firebase_database.onChildMoved(x0,x1,x2),
      _1604: x0 => x0.toJSON(),
      _1613: x0 => x0.val(),
      _1614: x0 => x0.toJSON(),
      _1623: (x0,x1) => globalThis.firebase_database.getDatabase(x0,x1),
      _1642: x0 => x0.reload(),
      _1649: (x0,x1) => globalThis.firebase_auth.updateProfile(x0,x1),
      _1652: x0 => x0.toJSON(),
      _1653: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1653(f,arguments.length,x0) }),
      _1654: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1654(f,arguments.length,x0) }),
      _1655: (x0,x1,x2) => x0.onAuthStateChanged(x1,x2),
      _1656: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1656(f,arguments.length,x0) }),
      _1657: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1657(f,arguments.length,x0) }),
      _1658: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1658(f,arguments.length,x0) }),
      _1659: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1659(f,arguments.length,x0) }),
      _1660: (x0,x1,x2) => x0.onIdTokenChanged(x1,x2),
      _1664: (x0,x1,x2) => globalThis.firebase_auth.createUserWithEmailAndPassword(x0,x1,x2),
      _1670: (x0,x1,x2) => globalThis.firebase_auth.sendPasswordResetEmail(x0,x1,x2),
      _1674: (x0,x1,x2) => globalThis.firebase_auth.signInWithEmailAndPassword(x0,x1,x2),
      _1679: x0 => x0.signOut(),
      _1680: (x0,x1) => globalThis.firebase_auth.connectAuthEmulator(x0,x1),
      _1703: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromResult(x0),
      _1718: x0 => globalThis.firebase_auth.getAdditionalUserInfo(x0),
      _1719: (x0,x1,x2) => ({errorMap: x0,persistence: x1,popupRedirectResolver: x2}),
      _1720: (x0,x1) => globalThis.firebase_auth.initializeAuth(x0,x1),
      _1726: x0 => globalThis.firebase_auth.OAuthProvider.credentialFromError(x0),
      _1729: (x0,x1) => ({displayName: x0,photoURL: x1}),
      _1741: () => globalThis.firebase_auth.debugErrorMap,
      _1744: () => globalThis.firebase_auth.browserSessionPersistence,
      _1746: () => globalThis.firebase_auth.browserLocalPersistence,
      _1748: () => globalThis.firebase_auth.indexedDBLocalPersistence,
      _1751: x0 => globalThis.firebase_auth.multiFactor(x0),
      _1752: (x0,x1) => globalThis.firebase_auth.getMultiFactorResolver(x0,x1),
      _1754: x0 => x0.currentUser,
      _1758: x0 => x0.tenantId,
      _1768: x0 => x0.displayName,
      _1769: x0 => x0.email,
      _1770: x0 => x0.phoneNumber,
      _1771: x0 => x0.photoURL,
      _1772: x0 => x0.providerId,
      _1773: x0 => x0.uid,
      _1774: x0 => x0.emailVerified,
      _1775: x0 => x0.isAnonymous,
      _1776: x0 => x0.providerData,
      _1777: x0 => x0.refreshToken,
      _1778: x0 => x0.tenantId,
      _1779: x0 => x0.metadata,
      _1781: x0 => x0.providerId,
      _1782: x0 => x0.signInMethod,
      _1783: x0 => x0.accessToken,
      _1784: x0 => x0.idToken,
      _1785: x0 => x0.secret,
      _1796: x0 => x0.creationTime,
      _1797: x0 => x0.lastSignInTime,
      _1802: x0 => x0.code,
      _1804: x0 => x0.message,
      _1816: x0 => x0.email,
      _1817: x0 => x0.phoneNumber,
      _1818: x0 => x0.tenantId,
      _1841: x0 => x0.user,
      _1844: x0 => x0.providerId,
      _1845: x0 => x0.profile,
      _1846: x0 => x0.username,
      _1847: x0 => x0.isNewUser,
      _1850: () => globalThis.firebase_auth.browserPopupRedirectResolver,
      _1855: x0 => x0.displayName,
      _1856: x0 => x0.enrollmentTime,
      _1857: x0 => x0.factorId,
      _1858: x0 => x0.uid,
      _1860: x0 => x0.hints,
      _1861: x0 => x0.session,
      _1863: x0 => x0.phoneNumber,
      _1873: x0 => ({displayName: x0}),
      _1874: x0 => ({photoURL: x0}),
      _1875: (x0,x1) => x0.getItem(x1),
      _1881: (x0,x1) => x0.appendChild(x1),
      _1884: (x0,x1) => x0.query(x1),
      _1885: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1885(f,arguments.length,x0) }),
      _1886: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1886(f,arguments.length,x0) }),
      _1887: (x0,x1,x2) => ({enableHighAccuracy: x0,timeout: x1,maximumAge: x2}),
      _1888: (x0,x1,x2,x3) => x0.getCurrentPosition(x1,x2,x3),
      _1889: (x0,x1) => x0.clearWatch(x1),
      _1890: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1890(f,arguments.length,x0) }),
      _1891: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1891(f,arguments.length,x0) }),
      _1892: (x0,x1,x2,x3) => x0.watchPosition(x1,x2,x3),
      _1894: (x0,x1,x2,x3,x4,x5,x6,x7) => ({apiKey: x0,authDomain: x1,databaseURL: x2,projectId: x3,storageBucket: x4,messagingSenderId: x5,measurementId: x6,appId: x7}),
      _1895: (x0,x1) => globalThis.firebase_core.initializeApp(x0,x1),
      _1896: x0 => globalThis.firebase_core.getApp(x0),
      _1897: () => globalThis.firebase_core.getApp(),
      _1902: x0 => x0.key,
      _1903: x0 => x0.priority,
      _1925: x0 => x0.ref,
      _1931: () => globalThis.firebase_core.SDK_VERSION,
      _1937: x0 => x0.apiKey,
      _1939: x0 => x0.authDomain,
      _1941: x0 => x0.databaseURL,
      _1943: x0 => x0.projectId,
      _1945: x0 => x0.storageBucket,
      _1947: x0 => x0.messagingSenderId,
      _1949: x0 => x0.measurementId,
      _1951: x0 => x0.appId,
      _1953: x0 => x0.name,
      _1954: x0 => x0.options,
      _1955: (x0,x1) => x0.debug(x1),
      _1956: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1956(f,arguments.length,x0) }),
      _1957: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1957(f,arguments.length,x0,x1) }),
      _1958: (x0,x1) => ({createScript: x0,createScriptURL: x1}),
      _1959: (x0,x1,x2) => x0.createPolicy(x1,x2),
      _1960: (x0,x1) => x0.createScriptURL(x1),
      _1961: (x0,x1,x2) => x0.createScript(x1,x2),
      _1962: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1962(f,arguments.length,x0) }),
      _1964: Date.now,
      _1966: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1967: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1968: () => typeof dartUseDateNowForTicks !== "undefined",
      _1969: () => 1000 * performance.now(),
      _1970: () => Date.now(),
      _1973: () => new WeakMap(),
      _1974: (map, o) => map.get(o),
      _1975: (map, o, v) => map.set(o, v),
      _1976: x0 => new WeakRef(x0),
      _1977: x0 => x0.deref(),
      _1984: () => globalThis.WeakRef,
      _1987: s => JSON.stringify(s),
      _1988: s => printToConsole(s),
      _1989: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      _1990: (o, p, r) => o.replaceAll(p, () => r),
      _1992: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1993: s => s.toUpperCase(),
      _1994: s => s.trim(),
      _1995: s => s.trimLeft(),
      _1996: s => s.trimRight(),
      _1997: (string, times) => string.repeat(times),
      _1998: Function.prototype.call.bind(String.prototype.indexOf),
      _1999: (s, p, i) => s.lastIndexOf(p, i),
      _2000: (string, token) => string.split(token),
      _2001: Object.is,
      _2006: (o, c) => o instanceof c,
      _2007: o => Object.keys(o),
      _2061: x0 => new Array(x0),
      _2063: x0 => x0.length,
      _2065: (x0,x1) => x0[x1],
      _2066: (x0,x1,x2) => { x0[x1] = x2 },
      _2069: (x0,x1,x2) => new DataView(x0,x1,x2),
      _2071: x0 => new Int8Array(x0),
      _2072: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _2074: x0 => new Uint8ClampedArray(x0),
      _2076: x0 => new Int16Array(x0),
      _2078: x0 => new Uint16Array(x0),
      _2080: x0 => new Int32Array(x0),
      _2082: x0 => new Uint32Array(x0),
      _2084: x0 => new Float32Array(x0),
      _2086: x0 => new Float64Array(x0),
      _2110: x0 => x0.random(),
      _2113: () => globalThis.Math,
      _2126: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _2127: (handle) => clearTimeout(handle),
      _2128: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _2129: (handle) => clearInterval(handle),
      _2130: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _2131: () => Date.now(),
      _2132: () => new Error().stack,
      _2133: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _2134: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _2135: (x0,x1) => x0.exec(x1),
      _2136: (x0,x1) => x0.test(x1),
      _2137: x0 => x0.pop(),
      _2139: o => o === undefined,
      _2141: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _2143: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _2144: o => o instanceof RegExp,
      _2145: (l, r) => l === r,
      _2146: o => o,
      _2147: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      _2148: o => o,
      _2149: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      _2150: o => o,
      _2151: b => !!b,
      _2152: o => o.length,
      _2154: (o, i) => o[i],
      _2155: f => f.dartFunction,
      _2156: () => ({}),
      _2157: () => [],
      _2159: () => globalThis,
      _2160: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _2161: (o, p) => p in o,
      _2162: (o, p) => o[p],
      _2163: (o, p, v) => o[p] = v,
      _2164: (o, m, a) => o[m].apply(o, a),
      _2166: o => String(o),
      _2167: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _2168: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._2168(f,arguments.length,x0) }),
      _2169: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._2169(f,arguments.length,x0,x1) }),
      _2170: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      _2171: o => [o],
      _2172: (o0, o1) => [o0, o1],
      _2173: (o0, o1, o2) => [o0, o1, o2],
      _2174: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _2175: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      _2176: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2177: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2180: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2181: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2182: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2183: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2184: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _2185: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _2186: x0 => new ArrayBuffer(x0),
      _2187: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _2189: x0 => x0.index,
      _2190: x0 => x0.groups,
      _2191: x0 => x0.flags,
      _2192: x0 => x0.multiline,
      _2193: x0 => x0.ignoreCase,
      _2194: x0 => x0.unicode,
      _2195: x0 => x0.dotAll,
      _2196: (x0,x1) => { x0.lastIndex = x1 },
      _2197: (o, p) => p in o,
      _2198: (o, p) => o[p],
      _2199: (o, p, v) => o[p] = v,
      _2200: (o, p) => delete o[p],
      _2215: () => new AbortController(),
      _2216: x0 => x0.abort(),
      _2217: (x0,x1,x2,x3,x4,x5) => ({method: x0,headers: x1,body: x2,credentials: x3,redirect: x4,signal: x5}),
      _2218: (x0,x1) => globalThis.fetch(x0,x1),
      _2219: (x0,x1) => x0.get(x1),
      _2220: (module,f) => finalizeWrapper(f, function(x0,x1,x2) { return module.exports._2220(f,arguments.length,x0,x1,x2) }),
      _2221: (x0,x1) => x0.forEach(x1),
      _2222: x0 => x0.getReader(),
      _2223: x0 => x0.cancel(),
      _2224: x0 => x0.read(),
      _2225: x0 => x0.trustedTypes,
      _2226: (x0,x1) => { x0.text = x1 },
      _2227: o => o instanceof Array,
      _2231: a => a.pop(),
      _2232: (a, i) => a.splice(i, 1),
      _2233: (a, s) => a.join(s),
      _2234: (a, s, e) => a.slice(s, e),
      _2237: a => a.length,
      _2239: (a, i) => a[i],
      _2240: (a, i, v) => a[i] = v,
      _2242: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      _2243: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _2245: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      _2246: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _2247: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      _2248: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _2249: o => o instanceof Uint8ClampedArray,
      _2250: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _2251: o => o instanceof Uint16Array,
      _2252: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _2253: o => o instanceof Int16Array,
      _2254: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _2255: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      _2256: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _2257: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      _2258: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _2260: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _2261: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      _2262: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _2263: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      _2264: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _2265: (a, i) => a.push(i),
      _2266: (t, s) => t.set(s),
      _2268: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _2270: o => o.buffer,
      _2271: o => o.byteOffset,
      _2272: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _2273: (b, o) => new DataView(b, o),
      _2274: (b, o, l) => new DataView(b, o, l),
      _2275: Function.prototype.call.bind(DataView.prototype.getUint8),
      _2276: Function.prototype.call.bind(DataView.prototype.setUint8),
      _2277: Function.prototype.call.bind(DataView.prototype.getInt8),
      _2278: Function.prototype.call.bind(DataView.prototype.setInt8),
      _2279: Function.prototype.call.bind(DataView.prototype.getUint16),
      _2280: Function.prototype.call.bind(DataView.prototype.setUint16),
      _2281: Function.prototype.call.bind(DataView.prototype.getInt16),
      _2282: Function.prototype.call.bind(DataView.prototype.setInt16),
      _2283: Function.prototype.call.bind(DataView.prototype.getUint32),
      _2284: Function.prototype.call.bind(DataView.prototype.setUint32),
      _2285: Function.prototype.call.bind(DataView.prototype.getInt32),
      _2286: Function.prototype.call.bind(DataView.prototype.setInt32),
      _2289: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _2290: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _2291: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _2292: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _2293: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _2294: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _2295: Function.prototype.call.bind(Number.prototype.toString),
      _2296: Function.prototype.call.bind(BigInt.prototype.toString),
      _2297: Function.prototype.call.bind(Number.prototype.toString),
      _2298: (d, digits) => d.toFixed(digits),
      _2314: () => globalThis.console,
      _2353: (x0,x1) => x0.error(x1),
      _3727: (x0,x1) => { x0.type = x1 },
      _3735: (x0,x1) => { x0.crossOrigin = x1 },
      _3737: (x0,x1) => { x0.text = x1 },
      _4194: () => globalThis.window,
      _4237: x0 => x0.location,
      _4256: x0 => x0.navigator,
      _4518: x0 => x0.trustedTypes,
      _4519: x0 => x0.sessionStorage,
      _4535: x0 => x0.hostname,
      _4626: x0 => x0.geolocation,
      _4631: x0 => x0.permissions,
      _4645: x0 => x0.userAgent,
      _6800: x0 => x0.signal,
      _6874: () => globalThis.document,
      _6957: x0 => x0.head,
      _8634: x0 => x0.value,
      _8636: x0 => x0.done,
      _9338: x0 => x0.url,
      _9340: x0 => x0.status,
      _9342: x0 => x0.statusText,
      _9343: x0 => x0.headers,
      _9344: x0 => x0.body,
      _9731: x0 => x0.state,
      _11048: x0 => x0.coords,
      _11049: x0 => x0.timestamp,
      _11051: x0 => x0.accuracy,
      _11052: x0 => x0.latitude,
      _11053: x0 => x0.longitude,
      _11054: x0 => x0.altitude,
      _11055: x0 => x0.altitudeAccuracy,
      _11056: x0 => x0.heading,
      _11057: x0 => x0.speed,
      _11058: x0 => x0.code,
      _11059: x0 => x0.message,
      _12967: x0 => x0.name,
      _13685: () => globalThis.console,
      _13713: x0 => x0.name,
      _13714: x0 => x0.message,
      _13715: x0 => x0.code,
      _13717: x0 => x0.customData,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });
    dartInstance.exports.$setThisModule(dartInstance);

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
