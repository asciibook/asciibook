(function() {
  var drawerEnabled = localStorage.getItem('drawerEnabled');
  var drawer = document.getElementById('drawer')

  var isDesktop = function() {
    return window.innerWidth > 1040;
  };

  var initDrawer = function() {
    if (isDesktop() && drawerEnabled != 'false') {
      drawer.classList.add('active');
    }
  }

  initDrawer();
  window.addEventListener('resize', initDrawer);

  document.getElementById('drawer-button').addEventListener('click', function() {
    drawer.classList.toggle('active');

    if (isDesktop()) {
      localStorage.setItem('drawerEnabled', drawer.classList.contains('active'));
    }
  })

  document.getElementById('drawer-backdrop').addEventListener('click', function() {
    drawer.classList.toggle('active');
  });

  document.querySelectorAll('#drawer a').forEach(function(element) {
    var url = new URL(element.href, document.baseURI).href;
    if (url == document.URL) {
      element.classList.add('active');
    }
  })
})();
