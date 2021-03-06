/* globals modulejs */

modulejs.define('CreateInstitution', ['jquery', 'NoosferoRoot', 'SelectElement'], function($, NoosferoRoot, SelectElement) {
  'use strict';

  var AJAX_URL = {
    new_institution:
      NoosferoRoot.urlWithSubDirectory("/plugin/gov_user/new_institution"),
    institution_already_exists:
      NoosferoRoot.urlWithSubDirectory("/plugin/gov_user/institution_already_exists"),
    get_institutions:
      NoosferoRoot.urlWithSubDirectory("/plugin/gov_user/get_institutions"),
    auto_complete_city:
      NoosferoRoot.urlWithSubDirectory("/account/search_cities")
  };

  function set_institution_field_name(name) {
    $("#input_institution").attr("value", name);
    $("#input_institution").autocomplete("search");
  }

  function show_public_institutions_fields() {
    $(".public-institutions-fields").show();
    $("#cnpj_required_field_mark").html("");
  }


  function show_private_institutions_fields() {
    $(".public-institutions-fields").hide();
    $("#institutions_governmental_power option").selected(0);
    $("#institutions_governmental_sphere option").selected(0);
    $("#institutions_juridical_nature option").selected(0);
    $("#cnpj_required_field_mark").html("(*)");
  }


  function get_comunity_post_data() {
    return {
      name : $("#community_name").val(),
      country : $("#community_country").val(),
      state : $("#community_state").val(),
      city : $("#community_city").val()
    };
  }


  function get_institution_post_data() {

    return {
      cnpj: $("#institutions_cnpj").val(),
      type: $("input[name='institutions[type]']:checked").val(),
      acronym : $("#institutions_acronym").val(),
      governmental_power: $("#institutions_governmental_power").selected().val(),
      governmental_sphere: $("#institutions_governmental_sphere").selected().val(),
      juridical_nature: $("#institutions_juridical_nature").selected().val(),
      corporate_name: $("#institutions_corporate_name").val(),
      siorg_code: $("#institutions_siorg_code").val(),
      sisp: $('input[name="institutions[sisp]"]:checked').val()
    };
  }


  function get_post_data() {
    var post_data = {};

    post_data.community = get_comunity_post_data();
    post_data.institutions = get_institution_post_data();

    return post_data;
  }


  // If the page has a user institution list, update it without repeating the institution
  function update_user_institutions_list() {
    $(".institution_container").append(get_clone_institution_data(institution_id));
    add_selected_institution_to_list(institution_id, institution_name);

    $(".remove-institution").click(remove_institution);
    $('#institution_modal').modal('toggle');
  }



  function success_ajax_response(response) {
    close_loading();

    if(response.success){
      var institution_name  = response.institution_data.name;
      var institution_id = response.institution_data.id;

      // Tell the user it was created
      window.display_notice(response.message);

      set_institution_field_name($("#community_name").val());

      // Close modal
      $(".modal-header .close").trigger("click");

      // Clear modal fields
      $("#institution_modal_body").html(window.sessionStorage.getItem("InstitutionModalBody"));
      $(".modal .modal-body div").show();

      // Reset modal events
      init_module();

      // If the user is is his profile edition page
      update_user_institutions_list();
    } else {
      var errors = create_error_list(response);

      $("#create_institution_errors").switchClass("hide-field", "show-field").html("<h2>"+response.message+"</h2>"+errors);

      show_errors_in_each_field(response.errors);
    }
  }

  function create_error_list(response){
    var errors = "<ul>";
    var field_name;

    for(var i =0;i<response.errors.length;i++) {
        errors += "<li>"+response.errors[i]+"</li>";
    }

    errors += "</ul>";
    return errors;
  }


  function show_errors_in_each_field(errors) {
    var error_keys = Object.keys(errors);

    // (field)|(field)|...
    var verify_error = new RegExp("(\\[" + error_keys.join("\\])|(\\[") + "\\])" );

    var fields_with_errors = $("#institution_dialog .formfield input").filter(function(index, field) {
      $(field).removeClass("highlight-error");
      return verify_error.test(field.getAttribute("name"));
    });

    var selects_with_errors = $("#institution_dialog .formfield select").filter(function(index, field) {
      $(field).removeClass("highlight-error");
      return verify_error.test(field.getAttribute("name"));
    });

    fields_with_errors.addClass("highlight-error");
    selects_with_errors.addClass("highlight-error");
  }


  function save_institution(evt) {
    evt.preventDefault();

    open_loading($("#loading_message").val());
    $.ajax({
      url: AJAX_URL.new_institution,
      data : get_post_data(),
      type: "POST",
      success: success_ajax_response,
      error: function() {
        close_loading();
        var error_message = $("#institution_error_message").val();
        $("#create_institution_errors").switchClass("hide-field", "show-field").html("<h2>"+error_message+"</h2>");
      }
    });
  }

  function institution_already_exists(){
    if( this.value.length >= 3 ) {
      $.get(AJAX_URL.institution_already_exists, {name:this.value}, function(response){
        if( response === true ) {
          $("#already_exists_text").switchClass("hide-field", "show-field");
        } else {
          $("#already_exists_text").switchClass("show-field", "hide-field");
        }
      });
    }
  }


  function get_clone_institution_data(value) {
    var user_institutions = $(".user_institutions").first().clone();
    user_institutions.val(value);

    return user_institutions;
  }

  function toggle_extra_fields_style_status(status) {
      if(status) {
        $('.comments-software-extra-fields').css({height: "180px" });
      } else {
        $('.comments-software-extra-fields').css({height: "140px" });
      }
  }


  function institution_autocomplete() {
    $("#input_institution").autocomplete({
      source : function(request, response){
        $.ajax({
          type: "GET",
          url: AJAX_URL.get_institutions,
          data: {query: request.term, selected_institutions: get_selected_institutions()},
          success: function(result){
            response(result);

            if( result.length === 0 ) {
              $('#institution_empty_ajax_message').switchClass("hide-field", "show-field");
              $('#input_institution').addClass("highlight-error");
              $('#add_institution_link').hide();
              toggle_extra_fields_style_status(true);
              $("#institution_modal").css({display: "none"});
            }
          },
          error: function(ajax, stat, errorThrown) {
            console.log('Link not found : ' + errorThrown);
          }
        });
      },

      minLength: 2,

      select : function (event, selected) {
        $('#institution_empty_ajax_message').switchClass("show-field", "hide-field");
        $('#add_institution_link').show();
        $('#input_institution').removeClass("highlight-error");
        toggle_extra_fields_style_status(false);
        $("#institution_selected").val(selected.item.id).attr("data-name", selected.item.label);
      }
    });
  }

  function get_selected_institutions() {
    var selected_institutions = []
    $('.institutions_added').find('li').each(function() {
      selected_institutions.push($(this).attr('data-institution'));
    });

    return selected_institutions;
  }

  function add_selected_institution_to_list(id, name) {
    var selected_institution = "<li data-institution='"+id+"'>"+name;
        selected_institution += "<a href='#' class='button without-text icon-remove remove-institution'></a></li>";

    $(".institutions_added").append(selected_institution);
  }

  function add_new_institution(evt) {
    evt.preventDefault();
    var selected = $("#institution_selected");
    var institution_already_added = $(".institutions_added li[data-institution='"+selected.val()+"']").length;

    if(selected.val().length > 0 && institution_already_added === 0) {
      //field that send the institutions to the server
      $(".institution_container").append(get_clone_institution_data(selected.val()));

      // Visualy add the selected institution to the list
      add_selected_institution_to_list(selected.val(), selected.attr("data-name"));
      $(this).hide();

      // clean the institution flag
      selected.val("").attr("data-name", "");
      $("#input_institution").val("");

      $(".remove-institution").click(remove_institution);
    }
  }


  function remove_institution(evt) {
    evt.preventDefault();
    var code = $(this).parent().attr("data-institution");

    $(".user_institutions[value="+code+"]").remove();
    $(this).parent().remove();
  }


  function add_mask_to_form_items() {
    $("#institutions_cnpj").mask("99.999.999/9999-99");
  }


  function show_hide_cnpj_city(country) {
    var cnpj = $("#institutions_cnpj").parent().parent();
    var city = $("#community_city");
    var city_label = $('label[for="community_city"]');
    var state = $("#community_state");
    var state_label = $('label[for="community_state"]');
    var inst_type = $("input[name='institutions[type]']:checked").val();

    if ( country === "-1" ) {
      $("#community_country").val("BR");
      country = "BR";
    }

    institution_type_actions(inst_type);

    if ( country !== "BR" ) {
      cnpj.hide();
      city.val('');
      city.hide();
      city_label.hide();
      state.val("");
      state.hide();
      state_label.hide();
    } else {
      cnpj.show();
      city.show();
      city_label.show();
      state_label.show();
      state.show();
    }
  }

  function institution_type_actions(type) {
    var country = $("#community_country").val();
    if( type === "PublicInstitution" && country == "BR") {
      show_public_institutions_fields();
    } else {
      show_private_institutions_fields();
    }
  }

  function autoCompleteCity() {
    var country_selected = $('#community_country').val();

    if(country_selected == "BR") {
      $('#community_city').autocomplete({
        source : function(request, response){
          $.ajax({
            type: "GET",
            url: AJAX_URL.auto_complete_city,
            data: {city_name: request.term, state_name: $("#community_state").val()},
            success: function(result){
              response(result);

              // There are two autocompletes in this page, the last one is modal
              // autocomplete just put it above the modal
              $(".ui-autocomplete").last().css("z-index", 1000);
            },
            error: function(ajax, stat, errorThrown) {
              console.log('Link not found : ' + errorThrown);
            }
          });
        },

        minLength: 3
      });
    } else {
      if ($('#community_city').data('autocomplete')) {
        $('#community_city').autocomplete("destroy");
        $('#community_city').removeData('autocomplete');
      }
    }
  }


  function set_institution_name_into_modal() {
    $("#community_name").val($("#input_institution").val());
  }


  function set_events() {
    $("input[name='institutions[type]']").click(function(){
      institution_type_actions(this.value);
    });

    $('#save_institution_button').click(save_institution);

    $("#community_name").keyup(institution_already_exists);

    $("#add_institution_link").click(add_new_institution);

    $(".remove-institution").click(remove_institution);

    $("#community_country").change(function(){
      show_hide_cnpj_city(this.value);
    });

    add_mask_to_form_items();

    institution_autocomplete();

    autoCompleteCity();
    $('#community_country').change(function(){
      autoCompleteCity();
    });

    $("#create_institution_link").click(set_institution_name_into_modal);
  }


  function init_module() {
    show_hide_cnpj_city($('#community_country').val());
    set_events();
  }

  return {
    isCurrentPage: function() {
      return $("#institution_form").length === 1;
    },

    init: init_module,

    institution_autocomplete: function(){
      institution_autocomplete();
    }
  };
});
