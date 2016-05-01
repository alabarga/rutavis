$(document).ready(function() {

  var types = document.querySelectorAll(".type-input");
  for (var t of types) {
    t.onchange = function(e) {
      Shiny.unbindAll();

      var self = this;
      ["active-pca", "active-autoencoder", "active-rbm"].forEach(function(name) {
        self.parentNode.parentNode.classList.remove(name);
      });
      self.parentNode.parentNode.classList.add("active-" + self.value);

      Shiny.bindAll();
    };
  }

  // --------------------------------------------------------
  // This will set all events for the layers form
  var containers = document.querySelectorAll(".layers");

  for (var c of containers) {
    var cont = c;
    var side = cont.getAttribute("data-side");
    var middle_layer = document.createElement("input");
    middle_layer.type = "number";
    middle_layer.name = side + "_layer1";
    middle_layer.value = 2;
    middle_layer.min = 2;
    middle_layer.max = 3;
    middle_layer.classList.add("small-input");
    middle_layer.classList.add("middle-layer");
    middle_layer.classList.add("layer");

    var add_button = document.createElement("input");
    add_button.type = "button";
    add_button.value = "+";
    add_button.classList.add("pure-button");
    add_button.classList.add("mini-button");
    add_button.classList.add("pure-button-primary");
    add_button.onclick = function() {
      Shiny.unbindAll();
      var side = this.parentNode.getAttribute("data-side");

      // Add one before
      var new_layer = document.createElement("input");
      new_layer.type = "number";
      new_layer.classList.add("small-input");
      new_layer.classList.add("layer");
      new_layer.value = 2;
      this.parentNode.insertBefore(new_layer, this.parentNode.querySelector(".middle-layer"));

      // Add one afterwards
      var new_layer2 = document.createElement("input");
      new_layer2.type = "number";
      new_layer2.classList.add("small-input");
      new_layer2.classList.add("layer");
      new_layer2.value = 2;
      this.parentNode.insertBefore(new_layer2, this.parentNode.querySelector(".middle-layer").nextSibling);

      // Renumerate all layers
      var layers = this.parentNode.querySelectorAll(".layer");
      for (var i = 0; i < layers.length; i++) {
        layers[i].name = side + "_layer" + (i + 1);
      }

      this.parentNode.querySelector(".layer-counter").value = 2 + 1*this.parentNode.querySelector(".layer-counter").value;
      Shiny.bindAll();
    };

    var remove_button = document.createElement("input");
    remove_button.type = "button";
    remove_button.value = "\u2212"; // minus symbol
    remove_button.classList.add("pure-button");
    remove_button.classList.add("mini-button");
    remove_button.classList.add("pure-button-primary");
    remove_button.classList.add("pure-button-remove");
    remove_button.onclick = function() {
      if (this.parentNode.querySelector(".middle-layer").previousSibling) {
        Shiny.unbindAll();
        this.parentNode.removeChild(this.parentNode.querySelector(".middle-layer").previousSibling);
        this.parentNode.removeChild(this.parentNode.querySelector(".middle-layer").nextSibling);

        // Renumerate all layers
        var layers = this.parentNode.querySelectorAll(".layer");
        for (var i = 0; i < layers.length; i++) {
          layers[i].name = this.parentNode.getAttribute("data-side") + "_layer" + (i + 1);
        }

        this.parentNode.querySelector(".layer-counter").value -= 2;
        Shiny.bindAll();
      }
    }

    var layer_counter = document.createElement("input");
    layer_counter.type = "number";
    layer_counter.style.display = "none";
    layer_counter.classList.add("layer-counter");
    layer_counter.name = side + "_layer_count";
    layer_counter.value = 1;

    cont.appendChild(middle_layer);
    cont.appendChild(add_button);
    cont.appendChild(remove_button);
    cont.appendChild(layer_counter);
  }
});
