function ready(callbackFunction){
  if(document.readyState != 'loading')
    callbackFunction(event)
  else
    document.addEventListener("DOMContentLoaded", callbackFunction)
}
ready(event => {
    console.log('DOM is ready.')
    document.getElementById('eval-inject').innerHTML = 345
})
