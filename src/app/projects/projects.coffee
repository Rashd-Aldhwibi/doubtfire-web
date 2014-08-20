angular.module("doubtfire.projects", [
  'doubtfire.units.partials'
  'doubtfire.projects.partials'
]
).config(($stateProvider) ->

  $stateProvider.state("projects#show",
    url: "/projects/:projectId?unitRole"
    views:
      main:
        controller: "ProjectsShowCtrl"
        templateUrl: "projects/projects-show.tpl.html"
      header:
        controller: "BasicHeaderCtrl"
        templateUrl: "common/header.tpl.html"

    data:
      pageTitle: "_Home_"
      roleWhitelist: ['Student', 'Tutor', 'Convenor', 'Admin']
  )
)
.controller("ProjectsShowCtrl", ($scope, $state, $stateParams, Project, UnitRole, headerService, alertService, taskService, unitService) ->
  $scope.unitLoaded = false
  $scope.studentProjectId = $stateParams.projectId
  $scope.projectLoaded = false
  
  Project.get { id: $scope.studentProjectId }, (project) ->
    # Clear any page-specific menus
    headerService.clearMenus()
    
    # Provide access to the Project's details
    $scope.project = project # the selected unit role
    
    $scope.submittedTasks = []
    
    if project
      unitService.getUnit project.unit_id, false, false, (unit) ->
        $scope.unit = unit # the unit related to the role
        unit.extendStudent project
        $scope.tasks = project.tasks

        $scope.submittedTasks = _.filter($scope.tasks, (task) -> _.contains(['ready_to_mark', 'discuss', 'complete', 'fix_and_resubmit', 'fix_and_include', 'redo'], task.status))
        $scope.submittedTasks = _.sortBy($scope.submittedTasks, (t) -> t.task_abbr).reverse()
        $scope.unitLoaded = true

      if $stateParams.unitRole?
        UnitRole.get { id: $stateParams.unitRole }, (unitRole) ->
          if unitRole.unit_id == project.unit_id
            $scope.assessingUnitRole = unitRole
      
      $scope.burndownData = project.burndown_chart_data
      $scope.projectLoaded = true
  # end get project
)