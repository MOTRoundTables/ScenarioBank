dfEmp  <- data.frame(EmpId = c(1, 2, 3),  Name = c("Josephine J. Evans", "Sophie D. Sessions", "Geneva R. Miller"))  
dfEmp

dfEmpAdr <- data.frame(EmployeeID = c(3, 2, 4),  Company = c("Monmax", "Heilig-Meyers", "MegaSolutions"))  
dfEmpAdr

d1 = merge(x = dfEmp, y = dfEmpAdr,   
      by.x = "EmpId", by.y = "EmployeeID", all = FALSE) 
d1



d2 =  dfEmp %>% left_join(dfEmpAdr, by = c('EmpId' = 'EmployeeID'))
d2

a = "EmpId"
b = "EmployeeID"
d4  = left_join(dfEmp, dfEmpAdr, by = c("{{a}}=={{b}}"))
{{a}}
 x = {{a}}+"=="+{{b}}
 
 

d <- merge(dfEmp, dfEmpAdr, by.x = a, by.y = b, all.x=TRUE)
d

d <- left_join(dfEmp, dfEmpAdr, by = c(a = b))
d

d  = left_join(dfEmp, dfEmpAdr, by=names(a=b))
d4  = left_join(dfEmp, dfEmpAdr, by=names(rlang::enquos(a)=rlang::enquos(b)))

d4  = left_join(dfEmp, dfEmpAdr, by=c(!!a==!!b))
d4  = left_join(dfEmp, dfEmpAdr, by = c({{a}}=={{b}}))


d4  = left_join(dfEmp, dfEmpAdr, by = c(a=b))
d4  = left_join(dfEmp, dfEmpAdr, by = c({{a}}=={{b}}))

d3 = merge(x = dfEmp, y = dfEmpAdr, by.x = a, by.y = b, all = FALSE) 
d3

d4  = left_join(dfEmp, dfEmpAdr, join_by = c(a=b))
d4  = left_join(dfEmp, dfEmpAdr, join_by = c({a}={b}))

d4  = left_join(dfEmp, dfEmpAdr, join_by = c({{a}}={{b}}))


                
xx = paste(a, "=", b, sep = "")
xx
d3 <- left_join(dfEmp, dfEmpAdr, join_by = c({xx}))
