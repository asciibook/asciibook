document.addEventListener('DOMContentLoaded', function() {
  // Drawer
  var drawer = document.querySelector('#drawer')
  var drawerToggle = document.querySelector('#drawer-toggle')

  drawerToggle.addEventListener('click', function() {
    drawer.classList.toggle('open')
    localStorage.setItem('drawerOpened', drawer.classList.contains('open'))
  })

  // restore drawer state
  if (localStorage.getItem('drawerOpened') == 'true') {
    drawer.classList.add('open')
  }

  // store drawer offset
  window.addEventListener('beforeunload', function() {
    localStorage.setItem('drawerScrollTop', drawer.scrollTop);
  });

  // restore drawer offset
  if (localStorage.getItem('drawerScrollTop')) {
    drawer.scrollTop = parseInt(localStorage.getItem('drawerScrollTop'));
  }

  // Dropdown
  document.querySelectorAll('.dropdown-toggle').forEach(function(element){
    var dropdown = element.closest('.dropdown')

    function openMenu() {
      dropdown.classList.add('open')
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
});
