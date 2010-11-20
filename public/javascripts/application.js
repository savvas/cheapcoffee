/*
Contents
1. Vars
2. Jquery Event Binding
3. Functions
*/


/*===============================
1. Vars - start
===============================*/

//Global settings
var opts = {
    animDur: 200,
    ajaxURLS:{
        submitCafe: 'http://www.site.com/url',
        geoCode: 'http://maps.googleapis.com/maps/api/geocode/json'
    }
};

//Global map object, holds all settings related to the google map thingy
var mapObj = {
        map: new Object(),
        initOptions: {
            navigationControl: true,
            mapTypeControl: false,
            scaleControl: false,
            zoom: 7,
            center: new google.maps.LatLng(37.978845,23.719482), //should be fb location :)
            mapTypeId: google.maps.MapTypeId.ROADMAP
        }
    };

/*===============================
1. Vars - end
===============================*/



/*===============================
2. Jquery Event Binding - start
===============================*/
$(document).ready(function(){

    //Cancel click on ajax links
    $('a[href=#]').click(function(){ return false; });

    //On load initialize google maps 
    initializeGMaps();

    //Toggle 'add cafeteria' form
    $('div.sidebar a.add-button, div.add-coffeeshop a.close').click(function(){
        if ($(this).hasClass('close')){
            _hideAddCoffeeShopForm();
        }else{
            _showAddCoffeeShopForm();
        }
    });

    //Change list
    $('a','p.tabs').click(_changeList);
    
    //Form inputs reset fields
    $('input[type=text]', 'div.add-coffeeshop')
    .focus(_focusFields)
    .blur(_blurFields);
   
    //Submit 'add cafeteria' form
    $('p.submit input', 'div.add-coffeeshop').click(_submitCoffeeForm);
    
});
/*===============================
2. Jquery Event Binding - end
===============================*/



/*===============================
3. Functions - start
===============================*/

//Retrieve user's location
function _setUserLocation(){
    var location;
    // Try W3C Geolocation (Preferred)
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            location = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
            mapObj.map.setCenter(location);
            mapObj.map.setZoom(14);
        });
    // Try Google Gears Geolocation
    } else if (google.gears) {
        var geo = google.gears.factory.create('beta.geolocation');
        geo.getCurrentPosition(function(position) {
            location = new google.maps.LatLng(position.latitude,position.longitude);
            mapObj.map.setCenter(location);
            mapObj.map.setZoom(14);
        });
    // Browser doesn't support Geolocation, set Athens as center
    }
}

//Google maps initialization function
function initializeGMaps(){
    mapObj.map = new google.maps.Map($('#map')[0], mapObj.initOptions);
    _setUserLocation();
}

//Show 'add cafeteria' form
function _showAddCoffeeShopForm(){
    $('a.add-button','div.sidebar ').addClass('close');
    $('div.add-coffeeshop', 'div.map-container').fadeIn(opts.animDur);
}

//Hide 'add cafeteria' form
function _hideAddCoffeeShopForm(){
    var $form = $('div.add-coffeeshop', 'div.map-container');  
    $('a.add-button','div.sidebar ').removeClass('close');
    $form.fadeOut(opts.animDur);  
    $form.find().addCla;
}

//Change list
function _changeList(){
   var  $links = $('a', 'p.tabs'),
        $lists = $('table', 'div.lists'),
        $target = $lists.filter('.' + $(this).attr('rel'));
   $links.removeClass('active');
   $(this).addClass('active');
   $lists.removeClass('active');
   $target.addClass('active');
}

//Form inputs reset fields
function _focusFields(){
    if ( $(this).attr('title')==$(this).val() ){
        $(this).val('');
    }
}
function _blurFields(){
    if ( $(this).val()=='' ){
        $(this).val($(this).attr('title'));
    }
}

//Submit 'add cafeteria' form
function _submitCoffeeForm(){
    if (!$(this).hasClass('disabled')){
        var coffeeAddress = $('#coffeeShopAddr', 'div.map-container').val(),
            coffeeName = $('#coffeeShopName', 'div.map-container').val(),
            coffeeType = $('#coffeeShopType', 'div.map-container').val(),
            coffeePrice = $('#coffeeShopPrice', 'div.map-container').val(),
            $sendingBox = $(this).parent(),
            $form = $('div.add-coffeeshop', 'div.map-container');
        $sendingBox.addClass('sending');
        $.ajax({
            url: opts.ajaxURLS.submitCafe, 
            data:{
                address: coffeeAddress,
                name: coffeeName,
                type: coffeeType,
                price: coffeePrice
            }, 
            success: function(){
                _resetForm();
                $form.fadeOut(opts.animDur);
            }
        });
    }
}

//Reset form fields
function _resetForm(){
    var $form = $('div.add-coffeeshop', 'div.map-container'); 
    $form.find('input[type=text]').each(function(){
        $(this).val($(this).attr('title'));
    });
    $form.find('#coffeeShopType').val('frappe');
    $form.find('#coffeeShopPrice').val('5');
    $form.find('p.submit').removeClass('sending');
}

/*===============================
3. Functions - end
===============================*/