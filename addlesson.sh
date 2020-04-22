test "$1" || { echo usage: sh addlesson.sh name >&2; exit 1; }

port=8107

# Set up lesson page
<<! cat >"$1.html"
<!doctype html>
<meta charset="utf-8">
<style>
body { font-family: sans-serif; }
.code { font-family: monospace; }
.italic { font-style: italic; }
li { margin: 10px 0; }
pre { tab-size: 2; }
</style>
<script src="https://livejs.com/live.js"></script>

<h1>Setup</h1>
Save <a download="$1-exercise.html" href="$1-exercise.html">this file</a> to a folder.
<br>Open Terminal.
<br>Type <span class="code">cd</span>, <span class="italic">space</span>, drag+drop that folder onto the terminal window, <span class="italic">enter</span>.
<br>Type <span class="code">python3 -m http.server $port</span><button class="copy">📋</button>, <span class="italic">enter</span>.
<br>Open <a href="http://localhost:$port/$1-exercise.html" target="blank">localhost:$port/$1-exercise.html</a>.
<br>Press <span class="code">⌘⌥I</span>.
<br>Under 'Network', make sure 'Disable cache' is checked.
<br>Click 'Console'.

<h1>Lesson</h1>

<h1>Exercises</h1>
<ol>
	<li>
	</li>
	<li>
	</li>
	<li>
	</li>
	<li>
	</li>
	<li>
	</li>
</ol>
<button id="showanswers">Show answers</button>
<div id="answers" style="display:none">
	<pre
></pre
	>
</div>

<script>
/* Return a new element with the provided properties set. */
function E(tag, props) {
	const e = document.createElement(tag);
	Object.keys(props||{}).forEach(k => {
		const v = props[k];
		if (v instanceof Object) {
			e[k] = {};
			Object.keys(v).forEach(k2 => {
				e[k][k2] = v[k2];
			});
		} else e[k] = v;
	});
	return e;
}

/* Array.from */
function Arrayfrom(l) {
	const arr = [];
	for (let i=0; i<l.length; i++) arr.push(l[i]);
	return arr;
}

/* .copy puts the preceding .code on the clipboard. */
Arrayfrom(document.querySelectorAll('.copy')).forEach(btn => {
	const s = btn.previousElementSibling.textContent;
	btn.addEventListener('click', () => {
		const eTmp = E('textarea', {style:{top:0,position:'fixed'}, textContent: s});
		document.body.appendChild(eTmp);
		eTmp.focus();
		eTmp.select();
		document.execCommand('copy');
		document.body.removeChild(eTmp);
	});
});

/* Toggle answers */
showanswers.addEventListener('click', () => {
	if (answers.style.display) {
		answers.style.display = '';
		showanswers.textContent = 'Hide answers';
		window.scroll(0, document.body.clientHeight);
	} else {
		answers.style.display = 'none';
		showanswers.textContent = 'Show answers';
	}
});
</script>
!

# Set up exercise page
<<! cat >"$1-exercise.html"
<!doctype html>

<!-- This will refresh the page when you save -->
<script src="https://livejs.com/live.js"></script>

<script>
</script>
!

# Add to the index
<<! ed -s index.html
/Generated/s/;/ '$1';/
w
!
vim -E -c /Generated -c Gen -c wq index.html >/dev/null

# Increment port
<<! ed -s addlesson.sh
/^port=/s/=[0-9]*/=$((port+1))/
w
!

# Open to edit
vim -o \
	-c ':let @c="a<span class=\"code\"></span>\<Left>\<Left>\<Left>\<Left>\<Left>\<Left>\<Left>"'
	-c '/<script>' \
	-c ':normal! o' \
	-c ":split $(echo "$1" | sed 's/ /\\ /g')-exercise.html" \
	-c ':wincmd j' \
	-c /Lesson \
	-c ':normal! zto' \
	"$1".html
