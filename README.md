# ABMSmoking

## Overview
### Purpose
This spatial agent-based model builds a conceptual model of human and environment interactions that affect cessation efforts of smokers as they navigate their environments. This agent-based model seeks to investigate how smokers and the study population are influenced by peer effects and aspects of the built environment as they navigate it across space and time.

Environmental components are abstracted into built and social environment factors, such as tobacco marketing points or designated tobacco-free-zones or clusters of smokers or dense commuting zones, and further explored to model how public health interventions may affect outcomes. 

### Entities, state variables, and scales
The model has two kinds of entities: persons and zones. Persons are abstainers or smokers, and smokers have different rates of smoking with most having low rates (or seeking to quit). Zones correspond to patch variables that are either green or red, and serve as abstractions of a built environment. Green patches correspond to "health zones" or areas that influence cessation efforts, and red patches correspond to "smoke zones" that influence smoking. Locations of both agents and patches are randomly places in the model. There may be up to 2000 agents. Up to ten percent of patches can be either red and/or green, depending on the slider selection. Temporal aspects of the model correspond to approximately a minute per tick, with cravings reset after ten ticks (or ten minutes). A condensed overview is as follows:

Agents:

•	Individuals (that smoke >5 cigarettes a day, have expressed interest to quit, with phone)

•	Environment (abstractions of built and social environment) 

Actions:

•	Smoke
•	Do not smoke

Individual-Environment interactions across space and time, with outcome testing: 
High risk of relapse/smoking:
•	Storefront tobacco advertising (built environment)

•	Nearby individuals are relapsing/smoking (social environment) 

	Low risk of relapse/smoking:
•	Designated tobacco-free zones (built environment) 
•	 Anti-tobacco marketing (built environment) 

Landscape: 
	●  Representation as 2D Euclidean space with different types/patches: 
		○  Tobacco vendors, high risk marketing (single red pixel) 
		○  Anti-tobacco marketing, low risk (single green pixel) 
		○  Tobacco-free zones (multiple red pixels) 
		○  Green spaces, such as parks (multiple green pixels) 

### Process overview and scheduling
For every tick,  smokers go through the following process. First, the decay rate for craving is increased by one. Then, the go through multiple influences: support of nearby abstainers (reduce craving); peer-pressure of nearby smokers (increase craving); peer-pressure of tobacco advertising (increase craving); and support of health zones or public health advertising (decrease craving). Then, if smoker is craving, they make a decision to smoke or not. After several ticks or 10 minutes and not smoking, the smoker will start craving and have their rate reset. This process is repeated until 1440 ticks are reached, and then the model is stopped.

```to go
  if ticks > 1440 [stop]
   
  ask turtles with [rD > 0.0]
   
     [set decays decays + 1
      
      support 
      
      peer-pressure 

      advertiseSmoke

	 noSmokeZone
      
      if satiation? = 0              ;; if craving, make a decision
      [  decide  ]
        
      if decays > maxdecay          ;; after 10 minutes, start craving
        [ set satiation? 0
          set rD random-gamma 2 0.25   
          set color red
          set decays 0] ] 
    
    ask turtles [ walk2 ]
    
  tick

end
```


## Design Concepts
### Basic principles
This model specifically tests aspects of two effects: social and built environment influence on smoking behavior. It seeks to answer: (i) how are smokers and the study population influenced by peer effects as they navigate their environment across space and time? and (ii) how are smokers and the study population influenced by aspects of the built environment as they navigate it across space and time? 

### Adaptation
Individuals can respond to changes in the environment based on social and spatial components; once craving, nearby agents and friends influence their decision to go out smoking or not. 

### Sensing
In this model, agents who are smokers can sense agents that are nearby. The nearby agents behavior, whether smoking or abstaining, can influence the agent's willingness to smoke. In addition, the agent can also sense aspects of their patch and nearby patches that may have positive or negative messaging that would impact their smoking decision. After assessing neighboring agents and patches, the agent decides on whether or not they should smoke.

### Interaction
Interaction between agents influences their smoking behaviors. Interactions between patches and agents, following their movement through the environment, can also impact agent behavior. Interactions occur at minute-level scales as agents walk through the space. 

## Details
###Intitialization
Data is initialized to the following parameters:

(need to update with table -- text is scrambled)

###Input Data
In this phase, no input data is included for the model. A more advanced model will incorporate geotagged transects through a rasterized city grid, as a comparison to the simulated data.

### Submodels
There are multiple submodels, summarized as follows:

#### Social Network
Within a tick, agents have a decision to smoke or not, depending on their satiation score and unique smoking rate. They can be influenced by peer pressure of those smoking around them, or to not smoke by being near abstainers. This influence contributes to their unique smoking rate.

#### Advertising Influence
Agents can also be influenced to smoke by aspects of the built environment that may encourage them to smoke, such as (abstracted) media campaigns or retail stores.  This influence contributes to their unique smoking rate by increasing it.

#### Health Zone Influence
Agents can alternatively, or additionally, be influenced to not smoke by aspects of the built environment that may encourage them not to smoke, such as (abstracted) smoke-free zones or public health advertising.  This influence contributes to their unique smoking rate by decreasing it.

#### Walking Mode
While preliminary, various forms of simulated walking are included in the model for further analysis. There are three forms of random walking through the space, with two versions of each, one moving a single step in a tick, and the other moving 10 steps to show increased speed in travel. These form the basis for future study in how transportation through the environment affects smoking behavior as agents interact with the built environment differently depending on transportation mode. 
