# Clone Orchestration Plan

## Overview

This project aims to facilitate the cloning of Orchestration Plans in Salesforce. The provided Apex class allows for the creation of a new Orchestration Plan with a specified name and the cloning of associated child records.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)

## Features

- Clone an existing Orchestration Plan.
- Copy child records associated with the Orchestration Plan, including:
  - Orchestration Scenarios
  - Orchestration Plan Definitions
  - Orchestration Item Definitions
  - Orchestration Item Dependency

## Installation

1. Clone the repository.
2. Deploy the provided Apex class (`CloneOrchestrationScenario.cls`) to your Salesforce environment.
3. Deploy the Lightning Web Component (LWC) `cloneOrchestrationPlan` and `productPicker`
4. Ensure necessary permissions for the executing user to perform cloning and insertion operations.
5. Add the LWC component to the Orchestration Scenario flexipage:
   - Navigate to Setup in your Salesforce org.
   - Go to the Object Manager and find `Orchestration Scenario`.
   - Open the `Lightning Record Pages` section.
   - Edit the flexipage that your Orchestration Scenario uses.
   - Drag and drop the `cloneOrchestrationPlan` component onto the flexipage in the desired location.
   - Save the flexipage.

Now, when viewing an Orchestration Scenario, the `cloneOrchestrationPlan` component should be visible and can be used for easy interaction with the cloned Orchestration Plans.


## Usage

Follow these steps to clone an Orchestration Plan:

1. Navigate to the Orchestration Scenario that serves as your starting point (it should have the last Orchestration Item).

2. Click on the 'Go to Cloning Setup' button provided by the added Lightning Web Component (LWC).
   ![Step 1](img/Step1.png)

3. The script will automatically identify all related Orchestration Scenarios.

4. For each identified Orchestration Scenario, enter the new name and select the destination product.
   ![Step 2](img/Step2.png)

5. Click the 'Clone Plan' button to initiate the cloning process.


