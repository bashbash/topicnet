

GLM tsk1c1d1 tsk1c1d2 tsk1c1d3 tsk1c2d1 tsk1c2d2 tsk1c2d3 tsk1c3d1 tsk1c3d2 tsk1c3d3 tsk1c4d1 tsk1c4d2 tsk1c4d3 tsk2c1d1 tsk2c1d2 tsk2c1d3 tsk2c2d1 tsk2c2d2 tsk2c2d3 tsk2c3d1 tsk2c3d2 tsk2c3d3 tsk2c4d1 tsk2c4d2 tsk2c4d3 tsk3c1d1 tsk3c1d2 tsk3c1d3 tsk3c2d1 
tsk3c2d2 tsk3c2d3 tsk3c3d1 tsk3c3d2 tsk3c3d3 tsk3c4d1 tsk3c4d2 tsk3c4d3 tsk4c1d1 tsk4c1d2 tsk4c1d3 tsk4c2d1 tsk4c2d2 tsk4c2d3 tsk4c3d1 tsk4c3d2 tsk4c3d3 tsk4c4d1 tsk4c4d2 tsk4c4d3 tsk5c1d1 tsk5c1d2 tsk5c1d3 tsk5c2d1 tsk5c2d2 tsk5c2d3 tsk5c3d1 tsk5c3d2 tsk5c3d3 tsk5c4d1 tsk5c4d2 tsk5c4d3 
  /WSFACTOR=task 5 Polynomial cond 4 Polynomial data 3 Polynomial 
  /MEASURE=time
  /METHOD=SSTYPE(3) 
  /EMMEANS=TABLES(task*cond) 
  /EMMEANS = TABLES(cond) COMPARE(cond)
  /EMMEANS = TABLES(cond*task) COMPARE(cond)
/EMMEANS = TABLES(cond*task) COMPARE(task)
 /PLOT=PROFILE(cond)
  /PLOT=PROFILE(cond*task)
  /PLOT=PROFILE(task*cond)
  /CRITERIA=ALPHA(.05) 
  /WSDESIGN=task cond data task*cond cond*task cond*data task*cond*data.


