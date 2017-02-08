Introducing ScrollbarAS2, from old site *fuoridalcerchio.net*, a very simple way to add scrollbars in your flash sites! 
It's easy to use even with frameworks like Gaia Framework.

How to use:

1. Include Scrollbar.as in your project folder.
2. Target a clip in your .fla that needs to be scrolled, create a scrollbar
(or use mine, just joking...) and in the library, set linkage for Class to Scrollbar.
3. In your .fla timeline, copy the code below. 
4. Test!

Test code: 

````javascript
scrolltext_mc.scrollbar.setScrollbar({
  content: the clip that needs to be scrolled,
  ruler: the ruler of the scrollbar (scrollbar is usually a clip itself to maintain reusability),
  background: the background of the scrollbar,
  mask: the mask clip used to mask content,
  scrollFactor: how much you scroll fast,
  blurred: if the scroll effect needs to be vertically blurred,
  blurFactor: how much it is blurred,
  pixelhinting: precision to the pixel, 
  cached: if the content can be cached (if static)
});
scrolltext_mc.scrollbar.start();
````
