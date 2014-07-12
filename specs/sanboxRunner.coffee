runInSandbox =  (script, context = {}) ->
  console.log(script)
  compileAndRun = ->    
    eval(script)

  compileAndRun.call(context)

  context

module.exports = runInSandbox
