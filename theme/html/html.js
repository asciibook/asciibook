function isDesktop() {
  return window.innerWidth > 1280;
}

document.addEventListener('DOMContentLoaded', function() {
  // Drawer
  var drawer = document.querySelector('#drawer');
  var drawerToggle = document.querySelector('#drawer-toggle');
  var drawerBackdrop = drawer.querySelector('.drawer-backdrop');

  drawerToggle.addEventListener('click', function() {
    drawer.classList.toggle('open');
    if (isDesktop()) {
      localStorage.setItem('drawerOpened', drawer.classList.contains('open'));
    }
  })

  drawerBackdrop.addEventListener('click', function() {
    drawer.classList.remove('open');
  })

  // restore drawer state
  if (isDesktop() && localStorage.getItem('drawerOpened') == 'true') {
    drawer.classList.add('open');
  }

  // store drawer offset
  window.addEventListener('beforeunload', function() {
    localStorage.setItem('drawerScrollTop', drawer.querySelector('.drawer-content').scrollTop);
  });

  // restore drawer offset
  if (localStorage.getItem('drawerScrollTop')) {
    drawer.querySelector('.drawer-content').scrollTop = parseInt(localStorage.getItem('drawerScrollTop'));
  }

  // Dropdown
  document.querySelectorAll('.dropdown-toggle').forEach(function(element){
    var dropdown = element.closest('.dropdown');

    function openMenu() {
      dropdown.classList.add('open');
      document.addEventListener('click', closeMenuOutside);
    }

    function closeMenu() {
      dropdown.classList.remove('open');
      document.removeEventListener('click', closeMenuOutside);
    }

    function closeMenuOutside(event) {
      if (!dropdown.contains(event.target)) {
        closeMenu();
      }
    }

    element.addEventListener('click', function() {
      if (dropdown.classList.contains('open')) {
        closeMenu();
      } else {
        openMenu();
      }
    });
  })

  // Hot keys
  document.addEventListener('keyup', function(event) {
    switch (event.which) {
      case 37:
        document.querySelector('.paginator-prev').click();
        break;
      case 39:
        document.querySelector('.paginator-next').click();
        break;
    }
  })

  // set default scroll element
  document.querySelector('.main-content').focus();

  document.body.classList.remove('preload');
});
