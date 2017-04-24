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

  
}

/*

Visualization constructor

*/

const singleTemplate = `
      <div class="columns">
        <div class="column is-narrow">
          <h1 class="title">Visualization settings</h1>
          
          <aside class="menu">
            <p class="menu-label">Data</p>
            <form>
              <div class="field">
                <label for="datasetId" class="label">Current dataset</label>
                <p class="control">
                  <output id="datasetId" class="shiny-text-output"></output>
                </p>
              </div>
              
              <div class="field">
                <label for="taskData" class="button is-primary">Upload new dataset</label>
                <p class="control">
                  <input id="taskData" name="taskData" class="input is-hidden" type="file" />
                </p>
              </div>
              
              <div class="field">
                <label for="taskCl" class="label">Class attribute</label>
                <p class="control">
                  <div class="select">
                    <select id="taskCl" name="taskCl"></select>
                  </div>
                </p>
              </div>
            </form>

            <hr>
            <p class="menu-label">Learner</p>
            <form>
              <div class="field">
                <label for="learnerCl" class="label">Type</label>
                <p class="control">
                  <div class="select">
                    <select id="learnerCl" name="learnerCl"></select>
                  </div>
                </p>
              </div>
              <div class="field">
                <span class="label">Network layer sizes</span>
                <p class="control">
                  <output id="learnerFirst"></output>
                  <input type="number" class="input" min=1 value=2>
                  <output id="learnerLast"></output>
                </p>
              </div>
              <div class="field">
                <span class="label">Activation type</span>
                <p class="control">
                  <div class="select">
                    <select id="learnerAct" name="learnerAct"></select>
                  </div>
                </p>
              </div>
              <div class="field">
                <span class="label">Number of rounds (epochs)</span>
                <p class="control">
                  <input type="number" class="input" min=1 value=10 id="learnerRounds" name="learnerRounds">
                </p>
              </div>
            </form>

            <hr>
            <p class="menu-label">Visualization</p>
          </aside>
        </div>

        <div class="column">
          <figure class="highlight">
            <div id="bigPlot" class="shiny-plot-output"></div>
          </figure>
          <pre id="console" class="shiny-text-output"></pre>
        </div>
      </div>
`;

var Visualization = function(task, learner) {
  var viewNode = document.querySelector(".view-one");
  
  this.task = task;
  this.learner = learner;

  this.mainNode = document.createElement("div");
  
  this.populate = function() {
    this.mainNode.innerHTML = singleTemplate;
  };

  this.populate();

  this.select = function() {
    if (viewNode.hasChildNodes())
      viewNode.removeChild(viewNode.lastChild);

    viewnode.appendChild(this.mainNode);
  }
};

/*

Visualization management

*/

var visualizations = [];

window.addEventListener("ready", function() {
  var plus = document.querySelector(".new-visualization");
  plus.addEventListener("click", function() {
    var vis = new Visualization(new Task(), new Learner());
    visualizations.push(vis);
    vis.select();
  });
});

