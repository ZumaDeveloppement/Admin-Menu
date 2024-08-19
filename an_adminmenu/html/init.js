// Bought from https://a-n.tebex.io/
// For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
// For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim

$(document).ready(function(){
	window.addEventListener('message', function(event) {
		let item = event.data
		if (item.action == 'copy') {
			var node = document.createElement('textarea');
			var selection = document.getSelection();
			
			node.textContent = item.clipboard;
			document.body.appendChild(node);
			selection.removeAllRanges();
			node.select();
			document.execCommand('copy');
			console.log(item.clipboard + ' copied to clipboard!')
			selection.removeAllRanges();
			document.body.removeChild(node);
		}
	});
});

// Bought from https://a-n.tebex.io/
// For Support, Join my Discord: https://discord.gg/f2Nbv9Ebf5
// For custom services or help, check my Fiverr: https://www.fiverr.com/aymannajim