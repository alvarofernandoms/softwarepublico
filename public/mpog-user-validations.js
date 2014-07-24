function check_reactivate_account(value, input_object){
  jQuery.ajax({
    url : "/plugin/mpog_software/check_reactivate_account",
    type: "GET",
    data: { "email": value },
    success: function(response) {
      if( jQuery("#forgot_link").length == 0 )
        jQuery(input_object).parent().append(response);
      else
        jQuery("#forgot_link").html(response);
    },
    error: function(type, err, message) {
      console.log(type+" -- "+err+" -- "+message);
    }
  });
}

function put_brazil_based_on_email(){
  var suffixes = ['gov.br', 'jus.br', 'leg.br', 'mp.br'];
  var value = this.value;
  var input_object = this;

  suffixes.each(function(suffix){
    var has_suffix = new RegExp("(.*)"+suffix+"$", "i");

    if( has_suffix.test(value) )
      jQuery("#profile_data_country").val("BR");
  });

  check_reactivate_account(value, input_object)
}

function validate_email_format(){
  var correct_format_regex = /^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$/;

  if( this.value.length > 0 ) {
    if(correct_format_regex.test(this.value))
      this.className = "validated";
    else
      this.className = "invalid";
  } else
    this.className = "";
}

function institution_autocomplete() {
  jQuery("#input_institution").autocomplete({
    source : function(request, response){
      jQuery.ajax({
        type: "GET",
        url: "/plugin/mpog_software/get_institutions",
        data: {query: request.term},
        success: function(result){
          response(result);

          if( result.length == 0 ) {
            jQuery('#institution_empty_ajax_message').switchClass("hide-field", "show-field");
          } else {
            jQuery('#institution_empty_ajax_message').switchClass("show-field", "hide-field");
          }
        },
        error: function(ajax, stat, errorThrown) {
          console.log('Link not found : ' + errorThrown);
        }
      });
    },

    minLength: 2,

    select : function (event, selected) {
      jQuery("#user_institution_id").val(selected.item.id);
    }
  });
}


jQuery(document).ready(function(){
  jQuery('#secondary_email_field').blur(
    validate_email_format
  );

  jQuery("#user_email").blur(
    put_brazil_based_on_email
  );

  jQuery('#secondary_email_field').focus(function() { jQuery('#secondary-email-balloon').fadeIn('slow'); });
  jQuery('#secondary_email_field').blur(function() { jQuery('#secondary-email-balloon').fadeOut('slow'); });

  jQuery('#role_field').focus(function() { jQuery('#role-balloon').fadeIn('slow'); });
  jQuery('#role_field').blur(function() { jQuery('#role-balloon').fadeOut('slow'); });

  jQuery('#area_interest_field').focus(function() { jQuery('#area-interest-balloon').fadeIn('slow'); });
  jQuery('#area_interest_field').blur(function() { jQuery('#area-interest-balloon').fadeOut('slow'); });

  institution_autocomplete();

  jQuery("#input_institution").blur(function(){
    if( this.value == "" )
      jQuery("#user_institution_id").val("");
  });
});
