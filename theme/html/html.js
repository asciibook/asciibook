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

  // Custom style
  document.body.dataset.fontSize = localStorage.getItem('fontSize') || '100';
  document.body.dataset.fontFamily = localStorage.getItem('fontFamily') || 'sans-serif';
  document.body.dataset.background = localStorage.getItem('background') || 'white';

  function updataFonsSizeText() {
    document.querySelector('#font-size-text').textContent = document.body.dataset.fontSize + '%';
  }
  updataFonsSizeText();

  function updateFontFamilyButton() {
    document.querySelectorAll('.font-family-options .button').forEach(function(button){
      if (button.dataset.value == document.body.dataset.fontFamily) {
        button.classList.add('active')
      } else {
        button.classList.remove('active')
      }
    });
  }
  updateFontFamilyButton();

  function updateBackgroundButton() {
    document.querySelectorAll('.background-options .button').forEach(function(button){
      if (button.dataset.value == document.body.dataset.background) {
        button.classList.add('active')
      } else {
        button.classList.remove('active')
      }
    });
  }
  updateBackgroundButton();

  function updateStyle(key, value) {
    localStorage.setItem(key, value);
    document.body.dataset[key] = value;
  }

  var fontSizeList = [50, 67, 75, 80, 90, 100, 110, 125, 150, 175, 200];
  document.querySelectorAll('.font-size-options .button').forEach(function(element){
    element.addEventListener('click', function() {
      var index = fontSizeList.indexOf(parseInt(document.body.dataset.fontSize));

      if (index == -1) {
        index = 5;
      }

      switch (this.dataset.action) {
        case 'add':
          index += 1
          break;
        case 'reduce':
          index -= 1
          break;
        default:
      }

      if (value = fontSizeList[index]) {
        updateStyle('fontSize', value);
        updataFonsSizeText();
      }
    });
  });

  document.querySelectorAll('.font-family-options .button').forEach(function(element) {
    element.addEventListener('click', function() {
      updateStyle('fontFamily', this.dataset.value);
      updateFontFamilyButton();
    });
  });

  document.querySelectorAll('.background-options .button').forEach(function(element) {
    element.addEventListener('click', function() {
      updateStyle('background', this.dataset.value);
      updateBackgroundButton();
    });
  });

  // set default scroll element
  document.querySelector('.main-content').focus();

  document.body.classList.remove('preload');
});
