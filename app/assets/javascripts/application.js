// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require chartkick
//= require Chart.bundle
//= require_tree .

function submitParentForm(event) {
  $(event.target).parents('form[data-remote=true]').find('[type=submit]').click();
}

$(document).ready(function() {
  $('body').on('ajax:success', 'form[data-remote=true]', function(event) {
    event.target.parentElement.innerHTML = event.detail[2].response;
    $('#transaction-updated-toast').toast('show');
  });

  $('body').on('click', 'form[data-remote=true] :checkbox', submitParentForm)
  $('body').on('change', 'form[data-remote=true] select', submitParentForm)
})
