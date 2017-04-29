"use strict";

/*

View constructor

*/
var View = function(name) {
  this.node = document.querySelector(".view-" + name);
  this.enableButton = document.querySelector(".enable-" + name);
  this.disableButtons = document.querySelectorAll(".enable-view:not(.enable-" + name + ")");
  
  this.enable = function() {
    this.node.classList.remove("is-hidden");
    this.enableButton.classList.add("is-active");
    return this;
  };

  this.disable = function() {
    this.node.classList.add("is-hidden");
    this.enableButton.classList.remove("is-active");
    return this;
  }

  this.enableButton.addEventListener("click", this.enable.bind(this));
  for (let button of this.disableButtons) {
    button.addEventListener("click", this.disable.bind(this));
  }
};

// The interface has 3 views
window.addEventListener("load", function() {
  var views = [
    new View("one"),
    new View("grid"),
    new View("list")
  ];
  views[0].enable();
  views[1].disable();
  views[2].disable();
});

/*

Task constructor

*/
var Task = function() {
  
};

/*

Learner constructor

*/
var Learner = function() {
  this.type = null;
  this.nodeType = document.createElement("select");

  this.activation = null;
  this.nodeActivation = document.createElement("select");

  this.hidden = null;
  this.nodesHidden = [document.createElement("input")];
  
  this.rounds = 0;
  this.nodeRounds = document.createElement("input");
};

/*

Visualization constructor

*/

const singleTemplate = `
      <div class="columns">
        <div class="column is-narrow">
          <h1 class="title">Visualization {index}</h1>
          <h1 id="title{index}" class="shiny-text-output">Emptiness :(</h1>
          
          <aside class="menu">
            <p class="menu-label">Data</p>
            <form>
              <div class="field">
                <label for="datasetId{index}" class="label">Current dataset</label>
                <p class="control">
                  <output id="datasetId{index}" class="shiny-text-output"></output>
                </p>
              </div>
              
              <div class="field">
                <label for="taskData{index}" class="button is-primary">Upload new dataset</label>
                <p class="control">
                  <input id="taskData{index}" name="taskData{index}" class="input is-hidden" type="file" />
                </p>
              </div>
              
              <div class="field">
                <label for="taskCl{index}" class="label">Class attribute</label>
                <p class="control">
                  <div class="select">
                    <select id="taskCl{index}" name="taskCl{index}"></select>
                  </div>
                </p>
              </div>
            </form>

            <hr>
            <p class="menu-label">Learner</p>
            <form>
              <div class="field">
                <label for="learnerCl{index}" class="label">Type</label>
                <p class="control">
                  <div class="select">
                    <select id="learnerCl{index}" name="learnerCl{index}"></select>
                  </div>
                </p>
              </div>
              <div class="field">
                <span class="label">Network layer sizes</span>
                <p class="control">
                  <output id="learnerFirst{index}"></output>
                  <input type="number" class="input" min=1 value=2>
                  <output id="learnerLast{index}"></output>
                </p>
              </div>
              <div class="field">
                <span class="label">Activation type</span>
                <p class="control">
                  <div class="select">
                    <select id="learnerAct{index}" name="learnerAct{index}"></select>
                  </div>
                </p>
              </div>
              <div class="field">
                <span class="label">Number of rounds (epochs)</span>
                <p class="control">
                  <input type="number" class="input" min=1 value=10 id="learnerRounds{index}" name="learnerRounds{index}">
                </p>
              </div>
            </form>

            <hr>
            <p class="menu-label">Visualization</p>
          </aside>
        </div>

        <div class="column">
          <figure class="highlight">
            <div id="bigPlot{index}" class="shiny-plot-output"></div>
          </figure>
          <pre id="console{index}" class="shiny-text-output"></pre>
        </div>
      </div>
`;

var Visualization = function(index, task, learner) {
  
  this.task = task;
  this.learner = learner;

  this.mainNode = document.createElement("div");
  
  this.populate = function() {
    this.mainNode.innerHTML = singleTemplate.replace(/\{index\}/g, index + 1);
  };

  this.populate();

  this.generate = function() {
    // acumular parámetros de task, learner
    var taskParams = 1, learnerParams = 0;
    Shiny.onInputChange("visualization", {task: taskParams, learner: learnerParams});
  }

  this.generate();
};

/*

Visualization management

*/

var _VisHandler = function() {
  var visualizations = [];
  var tabs = [];
  var viewNode = document.querySelector(".view-one");
  var plusNode = document.querySelector(".new-visualization");
  var tabsNode = plusNode.parentNode;
  
  var select = function(index) {
    if (index > -1 && index < visualizations.length) {
      Shiny.unbindAll();
      
      if (viewNode.hasChildNodes())
        viewNode.removeChild(viewNode.lastChild);

      viewNode.appendChild(visualizations[index].mainNode);

      var prev = tabsNode.querySelector(".is-active");
      if (prev)
        prev.classList.remove("is-active");
      tabs[index].classList.add("is-active");
      
      Shiny.onInputChange("currentVis", index + 1);
      Shiny.bindAll();
    }
  };
  
  var newTab = function(index) {
    // <a class="nav-item is-tab is-active">
    //   {index}
    // </a>
    var node = document.createElement("a");
    node.classList.add("nav-item");
    node.classList.add("is-tab");
    node.textContent = index + 1;
    node.addEventListener("click", (function() { select(index); }));
    return node;
  };

  var push = function(vis) {
    visualizations.push(vis);
    var tab = newTab(tabs.length);
    tabs.push(tab);
    tabsNode.insertBefore(tab, plusNode);
  };

  return {
    add: function() {
      Shiny.unbindAll();
      push(new Visualization(visualizations.length, new Task(), new Learner()));
      Shiny.onInputChange("visCount", visualizations.length);
      Shiny.bindAll();
      select(visualizations.length - 1);
    }
  };
};


window.addEventListener("load", function() {
  var VisHandler = _VisHandler();
  
  var plusNode = document.querySelector(".new-visualization");
  plusNode.addEventListener("click", function() {
    VisHandler.add();
  });

  Shiny.addCustomMessageHandler("bigPlot", function(plot) {
    console.log(plot);
    document.body.appendChild(plot);
  });

  
});

