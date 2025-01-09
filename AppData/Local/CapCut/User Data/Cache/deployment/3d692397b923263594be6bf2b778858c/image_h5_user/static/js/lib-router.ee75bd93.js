/*! For license information please see lib-router.ee75bd93.js.LICENSE.txt */
"use strict";(self.webpackChunkartist_op_web=self.webpackChunkartist_op_web||[]).push([[651],{77543:function(e,t,n){var r;n.r(t),n.d(t,{AbortedDeferredError:function(){return i.AbortedDeferredError},Await:function(){return a.KP},BrowserRouter:function(){return U},Form:function(){return L},HashRouter:function(){return x},Link:function(){return N},MemoryRouter:function(){return a.VA},NavLink:function(){return P},Navigate:function(){return a.Fg},NavigationType:function(){return i.Action},Outlet:function(){return a.j3},Route:function(){return a.AW},Router:function(){return a.F0},RouterProvider:function(){return a.pG},Routes:function(){return a.Z5},ScrollRestoration:function(){return D},UNSAFE_DataRouterContext:function(){return a.w3},UNSAFE_DataRouterStateContext:function(){return a.FR},UNSAFE_LocationContext:function(){return a.gd},UNSAFE_NavigationContext:function(){return a.Us},UNSAFE_RouteContext:function(){return a.pW},UNSAFE_useRouteId:function(){return a.Yi},UNSAFE_useScrollRestoration:function(){return q},createBrowserRouter:function(){return b},createHashRouter:function(){return R},createMemoryRouter:function(){return a.bi},createPath:function(){return i.createPath},createRoutesFromChildren:function(){return a.is},createRoutesFromElements:function(){return a.i7},createSearchParams:function(){return d},defer:function(){return i.defer},generatePath:function(){return i.generatePath},isRouteErrorResponse:function(){return i.isRouteErrorResponse},json:function(){return i.json},matchPath:function(){return i.matchPath},matchRoutes:function(){return i.matchRoutes},parsePath:function(){return i.parsePath},redirect:function(){return i.redirect},renderMatches:function(){return a.Oe},resolvePath:function(){return i.resolvePath},unstable_HistoryRouter:function(){return A},unstable_useBlocker:function(){return a.aQ},unstable_usePrompt:function(){return $},useActionData:function(){return a.nA},useAsyncError:function(){return a.iG},useAsyncValue:function(){return a.qv},useBeforeUnload:function(){return Z},useFetcher:function(){return z},useFetchers:function(){return Y},useFormAction:function(){return J},useHref:function(){return a.oQ},useInRouterContext:function(){return a.GV},useLinkClickHandler:function(){return H},useLoaderData:function(){return a.f_},useLocation:function(){return a.TH},useMatch:function(){return a.bS},useMatches:function(){return a.SN},useNavigate:function(){return a.s0},useNavigation:function(){return a.HJ},useNavigationType:function(){return a.ur},useOutlet:function(){return a.pC},useOutletContext:function(){return a.bx},useParams:function(){return a.UO},useResolvedPath:function(){return a.WU},useRevalidator:function(){return a.xW},useRouteError:function(){return a.lk},useRouteLoaderData:function(){return a.V4},useRoutes:function(){return a.V$},useSearchParams:function(){return M},useSubmit:function(){return W}});var o=n(50959),a=n(19198),i=n(61663);function u(){return u=Object.assign?Object.assign.bind():function(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var r in n)Object.prototype.hasOwnProperty.call(n,r)&&(e[r]=n[r])}return e},u.apply(this,arguments)}function l(e,t){if(null==e)return{};var n,r,o={},a=Object.keys(e);for(r=0;r<a.length;r++)n=a[r],t.indexOf(n)>=0||(o[n]=e[n]);return o}const c="get",s="application/x-www-form-urlencoded";function f(e){return null!=e&&"string"==typeof e.tagName}function d(e){return void 0===e&&(e=""),new URLSearchParams("string"==typeof e||Array.isArray(e)||e instanceof URLSearchParams?e:Object.keys(e).reduce(((t,n)=>{let r=e[n];return t.concat(Array.isArray(r)?r.map((e=>[n,e])):[[n,r]])}),[]))}let m=null;const p=new Set(["application/x-www-form-urlencoded","multipart/form-data","text/plain"]);function h(e){return null==e||p.has(e)?e:null}function v(e,t){let n,r,o,a,u;if(f(l=e)&&"form"===l.tagName.toLowerCase()){let u=e.getAttribute("action");r=u?(0,i.stripBasename)(u,t):null,n=e.getAttribute("method")||c,o=h(e.getAttribute("enctype"))||s,a=new FormData(e)}else if(function(e){return f(e)&&"button"===e.tagName.toLowerCase()}(e)||function(e){return f(e)&&"input"===e.tagName.toLowerCase()}(e)&&("submit"===e.type||"image"===e.type)){let u=e.form;if(null==u)throw new Error('Cannot submit a <button> or <input type="submit"> without a <form>');let l=e.getAttribute("formaction")||u.getAttribute("action");if(r=l?(0,i.stripBasename)(l,t):null,n=e.getAttribute("formmethod")||u.getAttribute("method")||c,o=h(e.getAttribute("formenctype"))||h(u.getAttribute("enctype"))||s,a=new FormData(u,e),!function(){if(null===m)try{new FormData(document.createElement("form"),0),m=!1}catch(e){m=!0}return m}()){let{name:t,type:n,value:r}=e;if("image"===n){let e=t?t+".":"";a.append(e+"x","0"),a.append(e+"y","0")}else t&&a.append(t,r)}}else{if(f(e))throw new Error('Cannot submit element that is not <form>, <button>, or <input type="submit|image">');n=c,r=null,o=s,u=e}var l;return a&&"text/plain"===o&&(u=a,a=void 0),{action:r,method:n.toLowerCase(),encType:o,formData:a,body:u}}const g=["onClick","relative","reloadDocument","replace","state","target","to","preventScrollReset"],E=["aria-current","caseSensitive","className","end","style","to","children"],y=["reloadDocument","replace","method","action","onSubmit","submit","relative","preventScrollReset"];function b(e,t){return(0,i.createRouter)({basename:null==t?void 0:t.basename,future:u({},null==t?void 0:t.future,{v7_prependBasename:!0}),history:(0,i.createBrowserHistory)({window:null==t?void 0:t.window}),hydrationData:(null==t?void 0:t.hydrationData)||S(),routes:e,mapRouteProperties:a.us}).initialize()}function R(e,t){return(0,i.createRouter)({basename:null==t?void 0:t.basename,future:u({},null==t?void 0:t.future,{v7_prependBasename:!0}),history:(0,i.createHashHistory)({window:null==t?void 0:t.window}),hydrationData:(null==t?void 0:t.hydrationData)||S(),routes:e,mapRouteProperties:a.us}).initialize()}function S(){var e;let t=null==(e=window)?void 0:e.__staticRouterHydrationData;return t&&t.errors&&(t=u({},t,{errors:w(t.errors)})),t}function w(e){if(!e)return null;let t=Object.entries(e),n={};for(let[r,o]of t)if(o&&"RouteErrorResponse"===o.__type)n[r]=new i.ErrorResponse(o.status,o.statusText,o.data,!0===o.internal);else if(o&&"Error"===o.__type){let e=new Error(o.message);e.stack="",n[r]=e}else n[r]=o;return n}const C=(r||(r=n.t(o,2))).startTransition;function U(e){let{basename:t,children:n,future:r,window:u}=e,l=o.useRef();null==l.current&&(l.current=(0,i.createBrowserHistory)({window:u,v5Compat:!0}));let c=l.current,[s,f]=o.useState({action:c.action,location:c.location}),{v7_startTransition:d}=r||{},m=o.useCallback((e=>{d&&C?C((()=>f(e))):f(e)}),[f,d]);return o.useLayoutEffect((()=>c.listen(m)),[c,m]),o.createElement(a.F0,{basename:t,children:n,location:s.location,navigationType:s.action,navigator:c})}function x(e){let{basename:t,children:n,future:r,window:u}=e,l=o.useRef();null==l.current&&(l.current=(0,i.createHashHistory)({window:u,v5Compat:!0}));let c=l.current,[s,f]=o.useState({action:c.action,location:c.location}),{v7_startTransition:d}=r||{},m=o.useCallback((e=>{d&&C?C((()=>f(e))):f(e)}),[f,d]);return o.useLayoutEffect((()=>c.listen(m)),[c,m]),o.createElement(a.F0,{basename:t,children:n,location:s.location,navigationType:s.action,navigator:c})}function A(e){let{basename:t,children:n,future:r,history:i}=e,[u,l]=o.useState({action:i.action,location:i.location}),{v7_startTransition:c}=r||{},s=o.useCallback((e=>{c&&C?C((()=>l(e))):l(e)}),[l,c]);return o.useLayoutEffect((()=>i.listen(s)),[i,s]),o.createElement(a.F0,{basename:t,children:n,location:u.location,navigationType:u.action,navigator:i})}const F="undefined"!=typeof window&&void 0!==window.document&&void 0!==window.document.createElement,_=/^(?:[a-z][a-z0-9+.-]*:|\/\/)/i,N=o.forwardRef((function(e,t){let n,{onClick:r,relative:c,reloadDocument:s,replace:f,state:d,target:m,to:p,preventScrollReset:h}=e,v=l(e,g),{basename:E}=o.useContext(a.Us),y=!1;if("string"==typeof p&&_.test(p)&&(n=p,F))try{let e=new URL(window.location.href),t=p.startsWith("//")?new URL(e.protocol+p):new URL(p),n=(0,i.stripBasename)(t.pathname,E);t.origin===e.origin&&null!=n?p=n+t.search+t.hash:y=!0}catch(S){}let b=(0,a.oQ)(p,{relative:c}),R=H(p,{replace:f,state:d,target:m,preventScrollReset:h,relative:c});return o.createElement("a",u({},v,{href:n||b,onClick:y||s?r:function(e){r&&r(e),e.defaultPrevented||R(e)},ref:t,target:m}))}));const P=o.forwardRef((function(e,t){let{"aria-current":n="page",caseSensitive:r=!1,className:i="",end:c=!1,style:s,to:f,children:d}=e,m=l(e,E),p=(0,a.WU)(f,{relative:m.relative}),h=(0,a.TH)(),v=o.useContext(a.FR),{navigator:g}=o.useContext(a.Us),y=g.encodeLocation?g.encodeLocation(p).pathname:p.pathname,b=h.pathname,R=v&&v.navigation&&v.navigation.location?v.navigation.location.pathname:null;r||(b=b.toLowerCase(),R=R?R.toLowerCase():null,y=y.toLowerCase());let S,w=b===y||!c&&b.startsWith(y)&&"/"===b.charAt(y.length),C=null!=R&&(R===y||!c&&R.startsWith(y)&&"/"===R.charAt(y.length)),U=w?n:void 0;S="function"==typeof i?i({isActive:w,isPending:C}):[i,w?"active":null,C?"pending":null].filter(Boolean).join(" ");let x="function"==typeof s?s({isActive:w,isPending:C}):s;return o.createElement(N,u({},m,{"aria-current":U,className:S,ref:t,style:x,to:f}),"function"==typeof d?d({isActive:w,isPending:C}):d)}));const L=o.forwardRef(((e,t)=>{let n=W();return o.createElement(k,u({},e,{submit:n,ref:t}))}));const k=o.forwardRef(((e,t)=>{let{reloadDocument:n,replace:r,method:a=c,action:i,onSubmit:s,submit:f,relative:d,preventScrollReset:m}=e,p=l(e,y),h="get"===a.toLowerCase()?"get":"post",v=J(i,{relative:d});return o.createElement("form",u({ref:t,method:h,action:v,onSubmit:n?s:e=>{if(s&&s(e),e.defaultPrevented)return;e.preventDefault();let t=e.nativeEvent.submitter,n=(null==t?void 0:t.getAttribute("formmethod"))||a;f(t||e.currentTarget,{method:n,replace:r,relative:d,preventScrollReset:m})}},p))}));function D(e){let{getKey:t,storageKey:n}=e;return q({getKey:t,storageKey:n}),null}var B,T;function O(e){let t=o.useContext(a.w3);return t||(0,i.UNSAFE_invariant)(!1),t}function j(e){let t=o.useContext(a.FR);return t||(0,i.UNSAFE_invariant)(!1),t}function H(e,t){let{target:n,replace:r,state:u,preventScrollReset:l,relative:c}=void 0===t?{}:t,s=(0,a.s0)(),f=(0,a.TH)(),d=(0,a.WU)(e,{relative:c});return o.useCallback((t=>{if(function(e,t){return!(0!==e.button||t&&"_self"!==t||function(e){return!!(e.metaKey||e.altKey||e.ctrlKey||e.shiftKey)}(e))}(t,n)){t.preventDefault();let n=void 0!==r?r:(0,i.createPath)(f)===(0,i.createPath)(d);s(e,{replace:n,state:u,preventScrollReset:l,relative:c})}}),[f,s,d,r,u,n,e,l,c])}function M(e){let t=o.useRef(d(e)),n=o.useRef(!1),r=(0,a.TH)(),i=o.useMemo((()=>function(e,t){let n=d(e);if(t)for(let r of t.keys())n.has(r)||t.getAll(r).forEach((e=>{n.append(r,e)}));return n}(r.search,n.current?null:t.current)),[r.search]),u=(0,a.s0)(),l=o.useCallback(((e,t)=>{const r=d("function"==typeof e?e(i):e);n.current=!0,u("?"+r,t)}),[u,i]);return[i,l]}function I(){if("undefined"==typeof document)throw new Error("You are calling submit during the server render. Try calling submit within a `useEffect` or callback instead.")}function W(){let{router:e}=O(B.UseSubmit),{basename:t}=o.useContext(a.Us),n=(0,a.Yi)();return o.useCallback((function(r,o){void 0===o&&(o={}),I();let{action:a,method:i,encType:u,formData:l,body:c}=v(r,t);e.navigate(o.action||a,{preventScrollReset:o.preventScrollReset,formData:l,body:c,formMethod:o.method||i,formEncType:o.encType||u,replace:o.replace,fromRouteId:n})}),[e,t,n])}function K(e,t){let{router:n}=O(B.UseSubmitFetcher),{basename:r}=o.useContext(a.Us);return o.useCallback((function(o,a){void 0===a&&(a={}),I();let{action:u,method:l,encType:c,formData:s,body:f}=v(o,r);null==t&&(0,i.UNSAFE_invariant)(!1),n.fetch(e,t,a.action||u,{preventScrollReset:a.preventScrollReset,formData:s,body:f,formMethod:a.method||l,formEncType:a.encType||c})}),[n,r,e,t])}function J(e,t){let{relative:n}=void 0===t?{}:t,{basename:r}=o.useContext(a.Us),l=o.useContext(a.pW);l||(0,i.UNSAFE_invariant)(!1);let[c]=l.matches.slice(-1),s=u({},(0,a.WU)(e||".",{relative:n})),f=(0,a.TH)();if(null==e&&(s.search=f.search,s.hash=f.hash,c.route.index)){let e=new URLSearchParams(s.search);e.delete("index"),s.search=e.toString()?"?"+e.toString():""}return e&&"."!==e||!c.route.index||(s.search=s.search?s.search.replace(/^\?/,"?index&"):"?index"),"/"!==r&&(s.pathname="/"===s.pathname?r:(0,i.joinPaths)([r,s.pathname])),(0,i.createPath)(s)}(function(e){e.UseScrollRestoration="useScrollRestoration",e.UseSubmit="useSubmit",e.UseSubmitFetcher="useSubmitFetcher",e.UseFetcher="useFetcher"})(B||(B={})),function(e){e.UseFetchers="useFetchers",e.UseScrollRestoration="useScrollRestoration"}(T||(T={}));let V=0;function z(){var e;let{router:t}=O(B.UseFetcher),n=o.useContext(a.pW);n||(0,i.UNSAFE_invariant)(!1);let r=null==(e=n.matches[n.matches.length-1])?void 0:e.route.id;null==r&&(0,i.UNSAFE_invariant)(!1);let[l]=o.useState((()=>String(++V))),[c]=o.useState((()=>(r||(0,i.UNSAFE_invariant)(!1),function(e,t){return o.forwardRef(((n,r)=>{let a=K(e,t);return o.createElement(k,u({},n,{ref:r,submit:a}))}))}(l,r)))),[s]=o.useState((()=>e=>{t||(0,i.UNSAFE_invariant)(!1),r||(0,i.UNSAFE_invariant)(!1),t.fetch(l,r,e)})),f=K(l,r),d=t.getFetcher(l),m=o.useMemo((()=>u({Form:c,submit:f,load:s},d)),[d,c,f,s]);return o.useEffect((()=>()=>{t?t.deleteFetcher(l):console.warn("No router available to clean up from useFetcher()")}),[t,l]),m}function Y(){return[...j(T.UseFetchers).fetchers.values()]}const G="react-router-scroll-positions";let Q={};function q(e){let{getKey:t,storageKey:n}=void 0===e?{}:e,{router:r}=O(B.UseScrollRestoration),{restoreScrollPosition:l,preventScrollReset:c}=j(T.UseScrollRestoration),{basename:s}=o.useContext(a.Us),f=(0,a.TH)(),d=(0,a.SN)(),m=(0,a.HJ)();o.useEffect((()=>(window.history.scrollRestoration="manual",()=>{window.history.scrollRestoration="auto"})),[]),function(e,t){let{capture:n}=t||{};o.useEffect((()=>{let t=null!=n?{capture:n}:void 0;return window.addEventListener("pagehide",e,t),()=>{window.removeEventListener("pagehide",e,t)}}),[e,n])}(o.useCallback((()=>{if("idle"===m.state){let e=(t?t(f,d):null)||f.key;Q[e]=window.scrollY}sessionStorage.setItem(n||G,JSON.stringify(Q)),window.history.scrollRestoration="auto"}),[n,t,m.state,f,d])),"undefined"!=typeof document&&(o.useLayoutEffect((()=>{try{let e=sessionStorage.getItem(n||G);e&&(Q=JSON.parse(e))}catch(e){}}),[n]),o.useLayoutEffect((()=>{let e=t&&"/"!==s?(e,n)=>t(u({},e,{pathname:(0,i.stripBasename)(e.pathname,s)||e.pathname}),n):t,n=null==r?void 0:r.enableScrollRestoration(Q,(()=>window.scrollY),e);return()=>n&&n()}),[r,s,t]),o.useLayoutEffect((()=>{if(!1!==l)if("number"!=typeof l){if(f.hash){let e=document.getElementById(f.hash.slice(1));if(e)return void e.scrollIntoView()}!0!==c&&window.scrollTo(0,0)}else window.scrollTo(0,l)}),[f,l,c]))}function Z(e,t){let{capture:n}=t||{};o.useEffect((()=>{let t=null!=n?{capture:n}:void 0;return window.addEventListener("beforeunload",e,t),()=>{window.removeEventListener("beforeunload",e,t)}}),[e,n])}function $(e){let{when:t,message:n}=e,r=(0,a.aQ)(t);o.useEffect((()=>{"blocked"!==r.state||t||r.reset()}),[r,t]),o.useEffect((()=>{if("blocked"===r.state){window.confirm(n)?setTimeout(r.proceed,0):r.reset()}}),[r,n])}},19198:function(e,t,n){var r;n.d(t,{AW:function(){return ne},F0:function(){return re},FR:function(){return l},Fg:function(){return ee},GV:function(){return h},HJ:function(){return H},KP:function(){return ae},Oe:function(){return fe},SN:function(){return I},TH:function(){return v},UO:function(){return C},Us:function(){return s},V$:function(){return x},V4:function(){return K},VA:function(){return X},WU:function(){return U},Yi:function(){return j},Z5:function(){return oe},aQ:function(){return Q},bS:function(){return E},bi:function(){return me},bx:function(){return S},f_:function(){return W},gd:function(){return f},i7:function(){return se},iG:function(){return Y},is:function(){return se},j3:function(){return te},lk:function(){return V},nA:function(){return J},oQ:function(){return p},pC:function(){return w},pG:function(){return Z},pW:function(){return d},qv:function(){return z},s0:function(){return b},ur:function(){return g},us:function(){return de},w3:function(){return u},xW:function(){return M}});var o=n(50959),a=n(61663);function i(){return i=Object.assign?Object.assign.bind():function(e){for(var t=1;t<arguments.length;t++){var n=arguments[t];for(var r in n)Object.prototype.hasOwnProperty.call(n,r)&&(e[r]=n[r])}return e},i.apply(this,arguments)}const u=o.createContext(null);const l=o.createContext(null);const c=o.createContext(null);const s=o.createContext(null);const f=o.createContext(null);const d=o.createContext({outlet:null,matches:[],isDataRoute:!1});const m=o.createContext(null);function p(e,t){let{relative:n}=void 0===t?{}:t;h()||(0,a.UNSAFE_invariant)(!1);let{basename:r,navigator:i}=o.useContext(s),{hash:u,pathname:l,search:c}=U(e,{relative:n}),f=l;return"/"!==r&&(f="/"===l?r:(0,a.joinPaths)([r,l])),i.createHref({pathname:f,search:c,hash:u})}function h(){return null!=o.useContext(f)}function v(){return h()||(0,a.UNSAFE_invariant)(!1),o.useContext(f).location}function g(){return o.useContext(f).navigationType}function E(e){h()||(0,a.UNSAFE_invariant)(!1);let{pathname:t}=v();return o.useMemo((()=>(0,a.matchPath)(e,t)),[t,e])}function y(e){o.useContext(s).static||o.useLayoutEffect(e)}function b(){let{isDataRoute:e}=o.useContext(d);return e?function(){let{router:e}=B(k.UseNavigateStable),t=O(D.UseNavigateStable),n=o.useRef(!1);return y((()=>{n.current=!0})),o.useCallback((function(r,o){void 0===o&&(o={}),n.current&&("number"==typeof r?e.navigate(r):e.navigate(r,i({fromRouteId:t},o)))}),[e,t])}():function(){h()||(0,a.UNSAFE_invariant)(!1);let e=o.useContext(u),{basename:t,navigator:n}=o.useContext(s),{matches:r}=o.useContext(d),{pathname:i}=v(),l=JSON.stringify((0,a.UNSAFE_getPathContributingMatches)(r).map((e=>e.pathnameBase))),c=o.useRef(!1);return y((()=>{c.current=!0})),o.useCallback((function(r,o){if(void 0===o&&(o={}),!c.current)return;if("number"==typeof r)return void n.go(r);let u=(0,a.resolveTo)(r,JSON.parse(l),i,"path"===o.relative);null==e&&"/"!==t&&(u.pathname="/"===u.pathname?t:(0,a.joinPaths)([t,u.pathname])),(o.replace?n.replace:n.push)(u,o.state,o)}),[t,n,l,i,e])}()}const R=o.createContext(null);function S(){return o.useContext(R)}function w(e){let t=o.useContext(d).outlet;return t?o.createElement(R.Provider,{value:e},t):t}function C(){let{matches:e}=o.useContext(d),t=e[e.length-1];return t?t.params:{}}function U(e,t){let{relative:n}=void 0===t?{}:t,{matches:r}=o.useContext(d),{pathname:i}=v(),u=JSON.stringify((0,a.UNSAFE_getPathContributingMatches)(r).map((e=>e.pathnameBase)));return o.useMemo((()=>(0,a.resolveTo)(e,JSON.parse(u),i,"path"===n)),[e,u,i,n])}function x(e,t){return A(e,t)}function A(e,t,n){h()||(0,a.UNSAFE_invariant)(!1);let{navigator:r}=o.useContext(s),{matches:u}=o.useContext(d),l=u[u.length-1],c=l?l.params:{},m=(l&&l.pathname,l?l.pathnameBase:"/");l&&l.route;let p,g=v();if(t){var E;let e="string"==typeof t?(0,a.parsePath)(t):t;"/"===m||(null==(E=e.pathname)?void 0:E.startsWith(m))||(0,a.UNSAFE_invariant)(!1),p=e}else p=g;let y=p.pathname||"/",b="/"===m?y:y.slice(m.length)||"/",R=(0,a.matchRoutes)(e,{pathname:b});let S=L(R&&R.map((e=>Object.assign({},e,{params:Object.assign({},c,e.params),pathname:(0,a.joinPaths)([m,r.encodeLocation?r.encodeLocation(e.pathname).pathname:e.pathname]),pathnameBase:"/"===e.pathnameBase?m:(0,a.joinPaths)([m,r.encodeLocation?r.encodeLocation(e.pathnameBase).pathname:e.pathnameBase])}))),u,n);return t&&S?o.createElement(f.Provider,{value:{location:i({pathname:"/",search:"",hash:"",state:null,key:"default"},p),navigationType:a.Action.Pop}},S):S}function F(){let e=V(),t=(0,a.isRouteErrorResponse)(e)?e.status+" "+e.statusText:e instanceof Error?e.message:JSON.stringify(e),n=e instanceof Error?e.stack:null,r="rgba(200,200,200, 0.5)",i={padding:"0.5rem",backgroundColor:r};return o.createElement(o.Fragment,null,o.createElement("h2",null,"Unexpected Application Error!"),o.createElement("h3",{style:{fontStyle:"italic"}},t),n?o.createElement("pre",{style:i},n):null,null)}const _=o.createElement(F,null);class N extends o.Component{constructor(e){super(e),this.state={location:e.location,revalidation:e.revalidation,error:e.error}}static getDerivedStateFromError(e){return{error:e}}static getDerivedStateFromProps(e,t){return t.location!==e.location||"idle"!==t.revalidation&&"idle"===e.revalidation?{error:e.error,location:e.location,revalidation:e.revalidation}:{error:e.error||t.error,location:t.location,revalidation:e.revalidation||t.revalidation}}componentDidCatch(e,t){console.error("React Router caught the following error during render",e,t)}render(){return this.state.error?o.createElement(d.Provider,{value:this.props.routeContext},o.createElement(m.Provider,{value:this.state.error,children:this.props.component})):this.props.children}}function P(e){let{routeContext:t,match:n,children:r}=e,a=o.useContext(u);return a&&a.static&&a.staticContext&&(n.route.errorElement||n.route.ErrorBoundary)&&(a.staticContext._deepestRenderedBoundaryId=n.route.id),o.createElement(d.Provider,{value:t},r)}function L(e,t,n){var r;if(void 0===t&&(t=[]),void 0===n&&(n=null),null==e){var i;if(null==(i=n)||!i.errors)return null;e=n.matches}let u=e,l=null==(r=n)?void 0:r.errors;if(null!=l){let e=u.findIndex((e=>e.route.id&&(null==l?void 0:l[e.route.id])));e>=0||(0,a.UNSAFE_invariant)(!1),u=u.slice(0,Math.min(u.length,e+1))}return u.reduceRight(((e,r,a)=>{let i=r.route.id?null==l?void 0:l[r.route.id]:null,c=null;n&&(c=r.route.errorElement||_);let s=t.concat(u.slice(0,a+1)),f=()=>{let t;return t=i?c:r.route.Component?o.createElement(r.route.Component,null):r.route.element?r.route.element:e,o.createElement(P,{match:r,routeContext:{outlet:e,matches:s,isDataRoute:null!=n},children:t})};return n&&(r.route.ErrorBoundary||r.route.errorElement||0===a)?o.createElement(N,{location:n.location,revalidation:n.revalidation,component:c,error:i,children:f(),routeContext:{outlet:null,matches:s,isDataRoute:!0}}):f()}),null)}var k,D;function B(e){let t=o.useContext(u);return t||(0,a.UNSAFE_invariant)(!1),t}function T(e){let t=o.useContext(l);return t||(0,a.UNSAFE_invariant)(!1),t}function O(e){let t=function(e){let t=o.useContext(d);return t||(0,a.UNSAFE_invariant)(!1),t}(),n=t.matches[t.matches.length-1];return n.route.id||(0,a.UNSAFE_invariant)(!1),n.route.id}function j(){return O(D.UseRouteId)}function H(){return T(D.UseNavigation).navigation}function M(){let e=B(k.UseRevalidator),t=T(D.UseRevalidator);return{revalidate:e.router.revalidate,state:t.revalidation}}function I(){let{matches:e,loaderData:t}=T(D.UseMatches);return o.useMemo((()=>e.map((e=>{let{pathname:n,params:r}=e;return{id:e.route.id,pathname:n,params:r,data:t[e.route.id],handle:e.route.handle}}))),[e,t])}function W(){let e=T(D.UseLoaderData),t=O(D.UseLoaderData);if(!e.errors||null==e.errors[t])return e.loaderData[t];console.error("You cannot `useLoaderData` in an errorElement (routeId: "+t+")")}function K(e){return T(D.UseRouteLoaderData).loaderData[e]}function J(){let e=T(D.UseActionData);return o.useContext(d)||(0,a.UNSAFE_invariant)(!1),Object.values((null==e?void 0:e.actionData)||{})[0]}function V(){var e;let t=o.useContext(m),n=T(D.UseRouteError),r=O(D.UseRouteError);return t||(null==(e=n.errors)?void 0:e[r])}function z(){let e=o.useContext(c);return null==e?void 0:e._data}function Y(){let e=o.useContext(c);return null==e?void 0:e._error}!function(e){e.UseBlocker="useBlocker",e.UseRevalidator="useRevalidator",e.UseNavigateStable="useNavigate"}(k||(k={})),function(e){e.UseBlocker="useBlocker",e.UseLoaderData="useLoaderData",e.UseActionData="useActionData",e.UseRouteError="useRouteError",e.UseNavigation="useNavigation",e.UseRouteLoaderData="useRouteLoaderData",e.UseMatches="useMatches",e.UseRevalidator="useRevalidator",e.UseNavigateStable="useNavigate",e.UseRouteId="useRouteId"}(D||(D={}));let G=0;function Q(e){let{router:t,basename:n}=B(k.UseBlocker),r=T(D.UseBlocker),[u,l]=o.useState(""),[c,s]=o.useState(a.IDLE_BLOCKER),f=o.useCallback((t=>{if("function"!=typeof e)return!!e;if("/"===n)return e(t);let{currentLocation:r,nextLocation:o,historyAction:u}=t;return e({currentLocation:i({},r,{pathname:(0,a.stripBasename)(r.pathname,n)||r.pathname}),nextLocation:i({},o,{pathname:(0,a.stripBasename)(o.pathname,n)||o.pathname}),historyAction:u})}),[n,e]);return o.useEffect((()=>{let e=String(++G);return s(t.getBlocker(e,f)),l(e),()=>t.deleteBlocker(e)}),[t,s,l,f]),u&&r.blockers.has(u)?r.blockers.get(u):c}const q=(r||(r=n.t(o,2))).startTransition;function Z(e){let{fallbackElement:t,router:n,future:r}=e,[a,i]=o.useState(n.state),{v7_startTransition:c}=r||{},s=o.useCallback((e=>{c&&q?q((()=>i(e))):i(e)}),[i,c]);o.useLayoutEffect((()=>n.subscribe(s)),[n,s]);let f=o.useMemo((()=>({createHref:n.createHref,encodeLocation:n.encodeLocation,go:e=>n.navigate(e),push:(e,t,r)=>n.navigate(e,{state:t,preventScrollReset:null==r?void 0:r.preventScrollReset}),replace:(e,t,r)=>n.navigate(e,{replace:!0,state:t,preventScrollReset:null==r?void 0:r.preventScrollReset})})),[n]),d=n.basename||"/",m=o.useMemo((()=>({router:n,navigator:f,static:!1,basename:d})),[n,f,d]);return o.createElement(o.Fragment,null,o.createElement(u.Provider,{value:m},o.createElement(l.Provider,{value:a},o.createElement(re,{basename:d,location:a.location,navigationType:a.historyAction,navigator:f},a.initialized?o.createElement($,{routes:n.routes,state:a}):t))),null)}function $(e){let{routes:t,state:n}=e;return A(t,void 0,n)}function X(e){let{basename:t,children:n,initialEntries:r,initialIndex:i,future:u}=e,l=o.useRef();null==l.current&&(l.current=(0,a.createMemoryHistory)({initialEntries:r,initialIndex:i,v5Compat:!0}));let c=l.current,[s,f]=o.useState({action:c.action,location:c.location}),{v7_startTransition:d}=u||{},m=o.useCallback((e=>{d&&q?q((()=>f(e))):f(e)}),[f,d]);return o.useLayoutEffect((()=>c.listen(m)),[c,m]),o.createElement(re,{basename:t,children:n,location:s.location,navigationType:s.action,navigator:c})}function ee(e){let{to:t,replace:n,state:r,relative:i}=e;h()||(0,a.UNSAFE_invariant)(!1);let{matches:u}=o.useContext(d),{pathname:l}=v(),c=b(),s=(0,a.resolveTo)(t,(0,a.UNSAFE_getPathContributingMatches)(u).map((e=>e.pathnameBase)),l,"path"===i),f=JSON.stringify(s);return o.useEffect((()=>c(JSON.parse(f),{replace:n,state:r,relative:i})),[c,f,i,n,r]),null}function te(e){return w(e.context)}function ne(e){(0,a.UNSAFE_invariant)(!1)}function re(e){let{basename:t="/",children:n=null,location:r,navigationType:i=a.Action.Pop,navigator:u,static:l=!1}=e;h()&&(0,a.UNSAFE_invariant)(!1);let c=t.replace(/^\/*/,"/"),d=o.useMemo((()=>({basename:c,navigator:u,static:l})),[c,u,l]);"string"==typeof r&&(r=(0,a.parsePath)(r));let{pathname:m="/",search:p="",hash:v="",state:g=null,key:E="default"}=r,y=o.useMemo((()=>{let e=(0,a.stripBasename)(m,c);return null==e?null:{location:{pathname:e,search:p,hash:v,state:g,key:E},navigationType:i}}),[c,m,p,v,g,E,i]);return null==y?null:o.createElement(s.Provider,{value:d},o.createElement(f.Provider,{children:n,value:y}))}function oe(e){let{children:t,location:n}=e;return x(se(t),n)}function ae(e){let{children:t,errorElement:n,resolve:r}=e;return o.createElement(le,{resolve:r,errorElement:n},o.createElement(ce,null,t))}var ie;!function(e){e[e.pending=0]="pending",e[e.success=1]="success",e[e.error=2]="error"}(ie||(ie={}));const ue=new Promise((()=>{}));class le extends o.Component{constructor(e){super(e),this.state={error:null}}static getDerivedStateFromError(e){return{error:e}}componentDidCatch(e,t){console.error("<Await> caught the following error during render",e,t)}render(){let{children:e,errorElement:t,resolve:n}=this.props,r=null,i=ie.pending;if(n instanceof Promise)if(this.state.error){i=ie.error;let e=this.state.error;r=Promise.reject().catch((()=>{})),Object.defineProperty(r,"_tracked",{get:()=>!0}),Object.defineProperty(r,"_error",{get:()=>e})}else n._tracked?(r=n,i=void 0!==r._error?ie.error:void 0!==r._data?ie.success:ie.pending):(i=ie.pending,Object.defineProperty(n,"_tracked",{get:()=>!0}),r=n.then((e=>Object.defineProperty(n,"_data",{get:()=>e})),(e=>Object.defineProperty(n,"_error",{get:()=>e}))));else i=ie.success,r=Promise.resolve(),Object.defineProperty(r,"_tracked",{get:()=>!0}),Object.defineProperty(r,"_data",{get:()=>n});if(i===ie.error&&r._error instanceof a.AbortedDeferredError)throw ue;if(i===ie.error&&!t)throw r._error;if(i===ie.error)return o.createElement(c.Provider,{value:r,children:t});if(i===ie.success)return o.createElement(c.Provider,{value:r,children:e});throw r}}function ce(e){let{children:t}=e,n=z(),r="function"==typeof t?t(n):t;return o.createElement(o.Fragment,null,r)}function se(e,t){void 0===t&&(t=[]);let n=[];return o.Children.forEach(e,((e,r)=>{if(!o.isValidElement(e))return;let i=[...t,r];if(e.type===o.Fragment)return void n.push.apply(n,se(e.props.children,i));e.type!==ne&&(0,a.UNSAFE_invariant)(!1),e.props.index&&e.props.children&&(0,a.UNSAFE_invariant)(!1);let u={id:e.props.id||i.join("-"),caseSensitive:e.props.caseSensitive,element:e.props.element,Component:e.props.Component,index:e.props.index,path:e.props.path,loader:e.props.loader,action:e.props.action,errorElement:e.props.errorElement,ErrorBoundary:e.props.ErrorBoundary,hasErrorBoundary:null!=e.props.ErrorBoundary||null!=e.props.errorElement,shouldRevalidate:e.props.shouldRevalidate,handle:e.props.handle,lazy:e.props.lazy};e.props.children&&(u.children=se(e.props.children,i)),n.push(u)})),n}function fe(e){return L(e)}function de(e){let t={hasErrorBoundary:null!=e.ErrorBoundary||null!=e.errorElement};return e.Component&&Object.assign(t,{element:o.createElement(e.Component),Component:void 0}),e.ErrorBoundary&&Object.assign(t,{errorElement:o.createElement(e.ErrorBoundary),ErrorBoundary:void 0}),t}function me(e,t){return(0,a.createRouter)({basename:null==t?void 0:t.basename,future:i({},null==t?void 0:t.future,{v7_prependBasename:!0}),history:(0,a.createMemoryHistory)({initialEntries:null==t?void 0:t.initialEntries,initialIndex:null==t?void 0:t.initialIndex}),hydrationData:null==t?void 0:t.hydrationData,routes:e,mapRouteProperties:de}).initialize()}}}]);