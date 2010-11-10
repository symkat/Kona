/**
* jQuery.nsm_TOC
* Copyright (c) 2008-2009 Newmso - leevi(at)newism(dot)com(dot)au | http://newism.com.au
* Licensed under Creative Commons Attribution-Share Alike 3.0 Unported license. | http://creativecommons.org/licenses/by-sa/3.0/
* Date: 27 Dec 2008
*
* @projectDescription Generate a table of contents based on header tags in your html markup.
* http://newism.com.au
*
* @author Leevi Graham - Technical Director, Newism Pty Ltd
* @version 1.1.0
* @requires jQuery 1.2+ http://jquery.com
* @see http://github.com/newism/nsm.toc.jquery_plugin/tree/master
*
* @id jQuery.nsm_TOC
* @id jQuery.fn.nsm_TOC
* @param {Object} options Hash of settings, optional.
*	 @option {Boolean} append_toc Append the generated TOC to the toc_el
*	 @option {String, DOMElement, jQuery, Object} toc_el The element that the TOC will be appended to
*	 @option {String, DOMElement, jQuery} ignore A collection of header elements which are not included in the TOC.
*	 @option {String} hash_prefix The string prepended to the anchor hash target.
*	 @option {Number} start_depth The minimun header element to include. Ex: "1" will build the TOC starting with <h1> elements while "2" will build the TOC starting with <h2> elements
*	 @option {Number} end_depth The max header element to include. Ex: "5" will build the TOC stopping at (but including) <h5> elements while "6" will build the TOC stopping at (but including) <h6> elements
*	 @option {Boolean} prepend_toc_marker Prepend TOC markers to the header elements and the TOC list items
*	 @option {String} toc_marker_suffix The string added after the toc marker. Ex: If the TOC marker is 1.1.1 and the toc_marker_suffix is "." the final output will be: "1.1.1." If the TOC Marker is 1.2.3 and the number suffix is ")" the final output will be "1.2.3)"
*	 @option {String} toc_marker_seperator The string that divides the toc_marker levels. Ex: If the TOC marker levels are 1,1 & 1 and the toc_marker_seperator is "." the final output will be: "1.1.1" If the TOC marker levels are 1,1 & 1 and the toc_marker_seperator is "-" the final output will be: "1-1-1"
*	 @option {String} toc_marker_class The class to add to the header and TOC list element toc_marker span. Ex: <span class="toc-marker">1.2.3</span>
*	 @option {Boolean} append_top_links Add top links to each heading element in the TOC. Ex: <h1><span class="toc-marker">1</span> Heading 1 <a href="#top">Top</a></h1>
*	 @option {String} top_link_class The class to add to the top link anchor element. Ex: <a href="#top" class="top">Top</a>
*	 @option {Boolean} append_toc_header_class Append an extra class to headers listed in the TOC
*	 @option {String} toc_header_class The class to append to the TOC headers
* @return {jQuery} Returns the same jQuery object, for chaining.
*
* @example $('body').nsm_TOC();
*
* @example $('body').nsm_TOC({ hash_prefix: "h-"}); // Changes the hash prefix for the TOC links
* @example $('body').nsm_TOC({ start_depth: 2, end_depth: 5}); // Creates a TOC using heading elments 2-5 nested in the target element
* @example $('body').nsm_TOC({ add_top_links: false}); // Doesn't add top links to heading elements
*
* Notes:
*  - Influenced by: http://code.google.com/p/jqplanize/ & http://blog.rebeccamurphey.com/2007/12/24/jquery-table-of-contents-plugin-nested/
*	- Still a work in progress
*	- Not tested on all platforms
*/

(function($)
{
	// plugin definition
	$.fn.nsm_TOC = function(options)
	{
		log("nsm_TOC.js selection count: %c", this.size());

		// build main options before element iteration
		var opts = $.extend({}, $.fn.nsm_TOC.defaults, options);

		// iterate and reformat each matched element
		return this.each(function()
		{
			var $self 			= $(this);
			var o 				= $.meta ? $.extend({}, opts, $self.data()) : opts;
			var $toc 			= $current_ul = $("<ul />").addClass("l-0");

			var current_depth	= 0;
			var levels			= [0,0,0,0,0,0];
			var hash_segments	= [];

			// for each of our headers
			$(o.header_selector, $self).each(function(index, heading)
			{
				var $self 				= $(this);
				// get the current heading depth 1-6
				var header_depth 		= parseInt(heading.tagName.substring(1));

				// if the current depth is the s
				if (o.start_depth <= header_depth && header_depth <= o.end_depth && !$self.is(o.ignore))
				{
					var target_depth 	= header_depth - o.start_depth;
					var text 			= ($self.attr("title")) ? $self.attr("title") : $self.text();
					text 				= text.replace(/>/g, "&gt;").replace(/</g, "&lt;");
					var hash_text 		= text.replace(/[^0-9a-zA-Z\-]+/gi, "_").toLowerCase();

					// create an LI
					var $li = $("<li />");

					log("\nProcessing heading %o", $(heading).text());

					// same level
					if (target_depth == current_depth)
					{
						log("same depth (" + target_depth + ")");
						levels[current_depth + 1] = 0;
						delete hash_segments[current_depth + 1];
						$current_ul.append($li);
					}
					// going down
					else if (target_depth > current_depth)
					{
						// loop for non-consectutive heading levels
						// we can go from a level 1 to level 5
						while(target_depth > current_depth)
						{
							log("nesting because: " + target_depth + " > " + current_depth);

							// add one to the depth
							current_depth++;

							// new level so we reset the child level count
							levels[current_depth + 1] = 0;
							delete hash_segments[current_depth + 1];

							// if there is no LI in the current UL
							if(!$("li:last", $current_ul).length)
							{
								// add one
								$current_ul.append("<li>");
							}

							// create a new UL and add a class name
							$new_ul = $("<ul />").addClass("l-"+current_depth);

							// append the new UL to the last list item
							$("li:last", $current_ul).append($new_ul);

							// set the new UL to the current UL for the next loop
							$current_ul = $new_ul;
						}
						// append the list item
						$current_ul.append($li);
					}
					// coming up
					else if (target_depth < current_depth)
					{
						// loop for non-consectutive heading levels
						// we can go from a level 3 to level 1
						while(target_depth < current_depth)
						{
							log("unnesting because: "  + target_depth + " < " + current_depth);
							
							// delete the current level
							levels[current_depth] = 0;
							delete hash_segments[current_depth];

							// update the current depth
							current_depth--;
							
							// set the current UL to current UL's parent UL
							$current_ul = $current_ul.parent().parent();
						}
						// append the LI 
						$current_ul.append($li);
					}

					// add a new count to the current level for our TOC
					levels[current_depth]++;
					
					// Add a new hash segment to our hash segments array
					hash_segments[current_depth] = hash_text;

					// create the TOC integer marker and remove any extra 0's
					toc_marker = levels.join(o.toc_marker_separator).replace(/(\.0)+$/, "");
					log("TOC marker: %o", toc_marker);

					// create the hash link and remove duplicate colon seperators
					toc_hash_link = hash_segments.join(":").replace(/:{2,}/, "").replace(/:$/, "");
					log("TOC hash link: %o", toc_hash_link);

					// add a number suffix?
					prependText = toc_marker + o.toc_marker_suffix;

					// do the titles
					if(o.prepend_toc_marker)
					{
						$self.prepend('<span id="' + o.hash_prefix + toc_hash_link + '" class="' + o.toc_marker_class + '">' + prependText + '</span> ');
					}

					// append the top links
					if(o.append_top_links)
					{
						$self.append(" <a href='" + o.top_link_href + "' class='" + o.top_link_class + "'>Top</a>");
					}

					// append the TOC
					if(o.append_toc)
					{
						// do the TOC link
						link_toc_marker = (o.prepend_toc_marker) ? '<span class="' + o.toc_marker_class + '">' + prependText + '</span> ' : '';
						$li.addClass($self.attr("class")).prepend('<a href="#' + o.hash_prefix + toc_hash_link + '">' + link_toc_marker + text + '</a>');
					}

					// add TOC header classes
					if(o.append_toc_header_class)
					{
						$self.addClass(o.toc_header_class);
					}

				}
				
			});

			// append the TOC
			if(o.append_toc)
			{
				$(o.toc_el).append($toc);
			}
		});

		function log() {
			if (!$.fn.nsm_TOC.defaults.debug)
			{
				return;
			}
			try
			{
				console.log.apply(console, arguments);
			}
			catch(e)
			{
				try
				{
					opera.postError.apply(opera, arguments);
				}
				catch(e){}
			}
		}
	}

	// plugin defaults
	$.fn.nsm_TOC.defaults = {
		debug:						false,
		header_selector:			":header:visible", 
		append_toc:					true, 
		toc_el:						"body",
		ignore: 					".toc-ignore",
		hash_prefix: 				"toc-",
		start_depth:				1,
		end_depth: 					6,
		prepend_toc_marker:			true,
		toc_marker_suffix:			".",
		toc_marker_separator: 		".",
		toc_marker_class:			"toc-marker",
		append_top_links:			true,
		top_link_href:				"#",
		top_link_class:				"top",
		append_toc_header_class:	true,
		toc_header_class:			"toc-header"
	};

// end of closure
})(jQuery);