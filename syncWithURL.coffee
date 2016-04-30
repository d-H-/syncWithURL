#'use strict'


class UrlSync
  constructor: (@$location)->

  addParams: ($scope,params)->
    isArray = {}

    for k,v of params
      isArray[k] = Object.prototype.toString.call(v) == '[object Array]';  # test whether the default param is of type array

      $scope[k] = v    # add the param to the scope (default)
      if @$location.search()[k]?  # overwrite with url version, if available
        sv = @$location.search()[k]  # search value

        # if the default's an array but the search value isn't, it's probably because, when it was encoded, the array only had one value in it.
        # single value arrays are encoded the same way as regular non-array variables; the encoding's ambiguous.
        # Since the default param was an array, though, we'll assume that the url version was meant to me.
        #  We'll convert it to an array of length 1
        if isArray[k] and Object.prototype.toString.call(sv) != '[object Array]'  #
          sv = [sv]
        $scope[k] = sv    # overwrite the default variable with the url variable

      wd = ((f)->->
        #console.log "wd called: ",  {key: f,val: $scope[f]}
        {key: f,val: $scope[f]}
      )(k)   # watch delegate that's evaluated for changes every digest 
      deregistrationFunctions = []
      deregistrationFunctions.push $scope.$watch wd, (n,o)=>   
        #console.log "Watch function called for ",n,o, wd().key,wd().val
        @$location.search(n.key,n.val)
      , true

      # when the scope is destroyed, call the deregistration functions
      $scope.$on "$destroy", ()-> 
        console.log "scope destroyed, calling deregistration functions"
        for df in deregistrationFunctions
          console.log "calling df", df
          df()


angular.module('syncWithURL').provider "SyncWithUrl", ()->

  returnObj = {}

  returnObj.$get = ['$location', ($location)->
      #console.log "new UrlSync crteated"
      new UrlSync($location)
    ]

  returnObj
