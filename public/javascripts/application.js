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
var setLoc = 0,
    cur_lat = null,
    cur_lng = null,
    cur_address = null;
//Global map object, holds all settings related to the google map thingy
var mapObj = {
        map: new Object(),
        initOptions: {
            navigationControl: true,
            mapTypeControl: false,
            scaleControl: false,
            zoom: 15,
            center: new google.maps.LatLng(37.974290,23.730396), //should be fb location :)
            mapTypeId: google.maps.MapTypeId.ROADMAP
        }
    };

/*===============================
1. Vars - end
===============================*/



/*===============================
2. Jquery Event Binding - start
===============================*/
var infowindow = null;

function show_cafeterias_on_map(map, data) {
  infowindow = new google.maps.InfoWindow({
    content: "holding..."
  });


  var infowindow = new google.maps.InfoWindow();
  var markers_array = [];

  for(i=0; i < data.length; i++) {
    cafe = data[i].cafeteria;
    if ((cafe.name).indexOf('Starbucks', 0) > -1) {
      icon_path = '/images/starbucks.png';
    } else {
      icon_path = '/images/coffeePin.png';
    }

    cafe_point = new google.maps.LatLng(cafe.lat+0,cafe.lng+0);
    var marker = new google.maps.Marker({
        position: cafe_point,
        title: cafe.name,
        icon: icon_path,
        cafe_name: cafe.name+''
    });
    markers_array.push(marker);
  }

  for(i=0; i < markers_array.length; i++) {
    cur_marker = markers_array[i];
    google.maps.event.addListener(cur_marker, 'click', function() {
      infowindow.setContent(this.cafe_name);
      infowindow.open(map, this);
    });
    cur_marker.setMap(map);
  }
  _createLists(data);
}


$(document).ready(function(){

    //Cancel click on ajax links
    $('a[href=#]').click(function(){ return false; });

    //On load initialize google maps
    initializeGMaps();

    map = mapObj.map;

    google.maps.event.addListener(mapObj.map, 'zoom_changed', function() {
      // we are always a click back
      _setCurrentLocation();
    });

    google.maps.event.addListener(mapObj.map, 'dragend', function() {
      _setCurrentLocation();
    });

    //Toggle 'add cafeteria' form
    $('a.add-button, a.close').click(function(){
        if ($(this).hasClass('close')){
            _hideAddCoffeeShopForm();
        } else {
           $.ajax({
              url:'/cafeterias/reverse_geocode', 
              data: { pair: cur_lat+','+cur_lng }, 
              success: function(data){
                address = data.split("*");
                if (address[0]) $('#coffeeShopAddr').val(address[0]);
                if (address[1]) $('#coffeeShopCity').val(address[1]);
              }
           });
           _showAddCoffeeShopForm();
        }
        return false;
    });

    //Change list
    $('a','p.tabs').click(_changeList);

    //Form inputs reset fields
    $('input[type=text]', 'div.add-coffeeshop')
    .focus(_focusFields)
    .blur(_blurFields);

    //Submit 'add cafeteria' form
    $('p.submit input', 'div.add-coffeeshop').click(_submitCoffeeForm);
    
    // Focus map on list
    $("table.cheap-list tr").live('click',_changeFocus(event));
});
/*===============================
2. Jquery Event Binding - end
===============================*/



/*===============================
3. Functions - start
===============================*/
// Change focus of map
function _changeFocus(event){
   console.log(1);
   return false;
}

// Search 
function _search(){
   search = $('#search').val();
   alert(search);
   $.ajax({
      url: '/cafeterias/geocode',
      data: {search: search},
      success: function(data){
         pair = data.split(',');
         if (pair[0]){
            loc = new google.maps.LatLng(pair[0],pair[1]);
            map.setCenter(loc); 
            _setCurrentLocation();      
         } else {
            alert("No results found");
         }
      }
   });
   return false;
}

//Retrieve user's location
function _setUserLocation(){
    var location;
    // Try W3C Geolocation (Preferred)
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position) {
            location = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
            mapObj.map.setCenter(location);
            mapObj.map.setZoom(14);
            _setCurrentLocation(position.coords.latitude, position.coords.longitude);
        });
        setLoc == 1;
    // Try Google Gears Geolocation
    } else if (google.gears) {
        var geo = google.gears.factory.create('beta.geolocation');
        geo.getCurrentPosition(function(position) {
            location = new google.maps.LatLng(position.latitude,position.longitude);
            mapObj.map.setCenter(location);
            mapObj.map.setZoom(14);
            cur_lat = c.lat();
            cur_lng = c.lng();
        });
        setLoc == 1;
        // Browser doesn't support Geolocation, set Athens as center
    } else {
       
    }
    
}

function _setCurrentLocation(){
   ne = mapObj.map.getBounds().getNorthEast();
   sw = mapObj.map.getBounds().getSouthWest();
   c = mapObj.map.getCenter();
   cur_lat = c.lat();
   cur_lng = c.lng();
   ajax_url = '/search.json?sw_lat='+sw.lat()+'&sw_lng='+sw.lng()+'&ne_lat='+ne.lat()+
              '&ne_lng='+ne.lng()+'&c_lat='+c.lat()+'&c_lng='+c.lng();
   $.getJSON(ajax_url, function(data){
     show_cafeterias_on_map(map, data);
   });
}


//Google maps initialization function
function initializeGMaps(){
    mapObj.map = new google.maps.Map($('#map')[0], mapObj.initOptions);
    _setUserLocation();
    setTimeout('_initData()', 3000);
}

function _initData(){ 
   if (setLoc==0){
      sw = mapObj.map.getBounds().getSouthWest();
      ne = mapObj.map.getBounds().getNorthEast();
      c = mapObj.map.getCenter();
      ajax_url = '/search.json?sw_lat='+sw.lat()+'&sw_lng='+sw.lng()+'&ne_lat='+ne.lat()+
                 '&ne_lng='+ne.lng()+'&c_lat='+c.lat()+'&c_lng='+c.lng();
      $.getJSON(ajax_url, function(data){
        show_cafeterias_on_map(mapObj.map, data);
      });
   }
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
var d;
// Create the cafeteria lists in the right
function _createLists(data){ d=data;
    templch='{{#cafeterias}}<tr rel="{{ cafeteria/lat }},{{ cafeteria/lng }}"><td class="name">{{> link }}</td><td class="price">{{ cafeteria/price_1 }}  &#8364;</td></tr>{{/cafeterias}}';
    templne='{{#cafeterias}}<tr rel="{{ cafeteria/lat }},{{ cafeteria/lng }}"><td class="name">{{> link }}</td><td class="distance">{{ cafeteria/distance }} km.</td></tr>{{/cafeterias}}';

    row_template_cheap = Handlebars.compile(templch);
    row_template_near = Handlebars.compile(templne);

    partials = { "link": '<a href="/cafeterias/{{cafeteria/id}}" alt="{{cafeteria/name}}">{{cafeteria/name}}</a>'};
    cheapest = data;
    cheapest.sort(function (a, b) {
        return a['cafeteria'].price_1 > b['cafeteria'].price_1;
    });
    for (var i=0; i < cheapest.length; i++){
        cheapest[i]['cafeteria']['index'] = i+1;
    }
    $('table.cheap-list').html(row_template_cheap({'cafeterias':cheapest},{"partials": partials}));

    nearest = data;
    nearest.sort(function (a, b) {
        return a['cafeteria'].distance > b['cafeteria'].distance;
    });
    for (var i=0; i < nearest.length; i++){
        nearest[i]['cafeteria']['index'] = i+1;
    }
    $('table.near-list').html(row_template_near({'cafeterias':nearest},{"partials": partials}));
}

/*===============================
3. Functions - end
===============================*/

