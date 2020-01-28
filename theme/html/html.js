(function() {
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
})();
