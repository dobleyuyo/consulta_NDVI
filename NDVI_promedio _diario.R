
# PROCESA LAS CONSULTAS ESPACIALES DE NDVI
# CREA ARCHVIO DE EXCEL
# GRAFICOS DE PROMEDIO DIARIO
# GRAFICOS DE PROMEDIO ANUAL


# En caso de no estar, instalar los siguientes paquetes 
################################################################################

install.packages("gtools")
install.packages("ggplot2")
install.packages("foreign")
install.packages("Rcpp")
install.packages("readxl")
install.packages("xlsx")


#### Caragar los paquetes para la sesión ####
library(gtools)
library(readxl)
library(foreign)
library(rJava)
library(xlsxjars)
library(xlsx)



# Encontrar y enlistar los archivos ( el "archivo.dbf" de la consulta del NDVI) 
################################################################################

# dirección de la carpeta con los archivos a utilizar
setwd("C:\\Pablo QGIS\\Arrabio\\shapes")
ubicacion="C:\\Pablo QGIS\\Arrabio\\shapes"

# direcciòn de la carpeta de guardado
carpeta_guardado= "C:\\Pablo QGIS\\Arrabio\\shapes"

# Nombre del campo a analizar, este nombre se utiliza para nombrar los archivos finales
campo= "FORMOSA"

# Primer año a analizar, se utiliza como referencia para nombras los archivos finales
año=2012

# Función de procesado de la consulta NDVI
procesar_consulta_ndvi<-function(ubicacion,carpeta_guardado,campo,año){

# lista de los archivos a conusltar
# glob2rx("nombre compartido por los archivos * extension)
  lista_archivos<-list.files(ubicacion,pattern=glob2rx("consulta*.dbf"))
  
  
  
  #####
  # Tabla resumen anual para cada año :
  # promedio, máximo, mínimo y rango relativo
  ###############################################################################
  
  for(i in 1:length(lista_archivos)){
    ########################
    # Limpieza de variables#
    ########################
    prom_diario_año = 0
    prom_anual=0
    min_diario_año=0
    min_anual=0
    max_diario_año=0
    max_anual=0
    clases=0
    tabla_resumen =0
    
    #carga la base de datos a R
    consulta_ndvi<-read.dbf(lista_archivos[i])
    
    ########################################################
    # Ordenar columnas en base a los días del año juliano #
    #######################################################
    
    # Crea una lista en base a la cual se ordena la base de datos
    nombre_columnas<-c(names(consulta_ndvi))
    lista_ordenamiento<-as.list(mixedsort(unlist(nombre_columnas),decreasing =FALSE))
    
    #Ordena la base datos
    consulta_ndvi=consulta_ndvi[match(lista_ordenamiento,names(consulta_ndvi))]
    
    #################################
    # Limpieza de la base de datos #
    ################################
    
    # redonda los decimales a 3 dígitos.
    options(digits = 3)
    
    # elimina los valores de ndvi menores a 0.2
    consulta_ndvi[consulta_ndvi<0.2]<-NA
    
    #############
    # Cálculos #
    ############
    
    # Promedio diario de un año
    prom_diario_año = aggregate.data.frame(consulta_ndvi[c(3:25)],
                                           by=list(consulta_ndvi$clase),
                                           FUN=mean,na.rm=TRUE)
    
    prom_diario_año = prom_diario_año[-nrow(prom_diario_año),]
    is.na(prom_diario_año) <- sapply(prom_diario_año, is.nan)
    
    
    # Promedio anual
    prom_anual<- as.vector((rowMeans(prom_diario_año[-c(1)], na.rm=TRUE)))
    is.na(prom_anual) <- sapply(prom_anual, is.nan)
    
    # mínimo diario de un año
    min_diario_año = aggregate.data.frame(consulta_ndvi[c(3:25)],
                                          by=list(consulta_ndvi$clase),
                                          FUN=min,na.rm=TRUE)
    
    min_diario_año =min_diario_año[-nrow(min_diario_año),]
    is.na(min_diario_año) <- sapply(min_diario_año, is.infinite)
    
    # Mínimo anual
    min_anual <-as.vector(apply(min_diario_año[-1],1,min,na.rm=TRUE))
    is.na(min_anual) <- sapply(min_anual, is.infinite)
    
    # máximo diario de un año
    max_diario_año = aggregate.data.frame(consulta_ndvi[c(3:25)],
                                          by=list(consulta_ndvi$clase),
                                          FUN=max,na.rm=TRUE)
    
    max_diario_año =max_diario_año[-nrow(max_diario_año),]
    is.na(max_diario_año) <- sapply(max_diario_año, is.infinite)
    
    # Máximo anual
    max_anual <-as.vector(apply(max_diario_año[-1],1,max,na.rm=TRUE))
    is.na(max_anual) <- sapply(max_anual, is.infinite)
    
    
    #Crea una lista de todas las clases de la base de datos
    clases<-as.vector(unique(prom_diario_año[[1]]))
    
    # crea una tabla con el promedio, máximo, mínimo y rango reltivo anual
    tabla_resumen <- as.data.frame(clases)
    tabla_resumen$prom_anual=prom_anual
    tabla_resumen$max_anual=max_anual
    tabla_resumen$min_anual=min_anual
    tabla_resumen$rango_relativo=(tabla_resumen$max_anual-tabla_resumen$min_anual)/tabla_resumen$prom_anual
    
   
    # Guarda la tabla del año en curso como: "campo + año"
    assign(paste(campo,año+i-1,sep=" "),tabla_resumen, env=.GlobalEnv)
    assign(paste(campo,año+i-1,"diario",sep=" "),prom_diario_año, env=.GlobalEnv)
    
    # Guarda el promedio anual del año en curso como: "promedio + año +prom_anual"
    assign(paste("promedio",as.character(año+i-1),campo),tabla_resumen$prom_anual)
   
    ############################
    # Guardado en archivo excel#
    ###########################
    perido_archivo=paste(año,"-",año+length(lista_archivos),sep="")
    nombre_archivo=paste(`campo`,perido_archivo,"resumen.xls",sep=" ")
    locacion_archivo=paste(`carpeta_guardado`,`nombre_archivo`,sep="/")
    
    #escribe el promedio anual en una pestaña con el nombre del campo y año
    write.xlsx(format(`tabla_resumen`,digits = 3),`locacion_archivo`,
               sheetName= paste(campo,año+i-1,sep=" "),append=T)
    
    #escribe el promedio diario en una pestaña con el nombre del campo y año
    write.xlsx(format(`prom_diario_año`, digits = 3),`locacion_archivo`,
               sheetName= paste(campo,año+i-1,"diario",sep=" "),append=T)
    
    }
  
  
  #####
  # Tabla resumen del periodo analizado:
  # contiene las clases y el promedio anual para cada año
  #################################################################################
  
  # Crea una tabla vacía con las clases de ambientes
  tabla_resumen_2 <-as.data.frame(clases)
  
  # Llena la tabla con los promedios de cada año
  for (j in 1:length(lista_archivos)){
    #dato<-prom_diario_año[1]
    c<-get(paste("promedio",as.character(año+j-1),campo))
    tabla_resumen_2 <-cbind.data.frame(tabla_resumen_2,c)
    colnames(tabla_resumen_2)[ncol(tabla_resumen_2)]<-paste("prom",año+j-1,sep=" ")
    }
  
  assign(paste(campo,año,"-",año+length(lista_archivos)-1,sep=" "),tabla_resumen_2, env=.GlobalEnv)
  
  # Guardado en archivo excel#
  #escribe de cada año en una pestaña con el nombre del campo y periodo
  write.xlsx(format(`tabla_resumen_2`,digits = 3),`locacion_archivo`,
             sheetName= paste(campo,año,"-",año+length(lista_archivos)-1,sep=" "),append=T)
  
}



# Gráficos #

# NDVI PROMEDIO DIARIO #

#Nombre de la Figura
nombre_figura_diario="NDVI_prom_diario_2.png"

# Escribir las clases que se quieren graficar ; las clases de leyenda
clases_grafico_diario=t(`SJQ 2016 diario`[c(1,2,3,4,5,6),])
clases_leyenda_diario=`SJQ 2016 diario`[c(1,2,3,4,5,6),1]

# Se define el titulo del gráfico
titulo_grafico_diario="2016-2017"

# Función del gráfico #
ndvi_daily_average_graph<-function(nombre_figura_diario,clases_grafico_diario,clases_leyenda_diario,titulo_grafico_diario){
  # Se definen lo lìmites del eje y
  y_min_diario=min(as.numeric(unlist(clases_grafico_diario)),na.rm=TRUE)
  y_max_diario=max(as.numeric(unlist(clases_grafico_diario)),na.rm=TRUE)
  y_eje_diario_nombre="NDVI"


  # Etiquetas del eje x, días gregorianos del año hidrológico
  año_hidrologico<-list("28 Ago","13 Sept","29 Sept","15 Oct","31 Oct","16 Nov",
                         "02 Dic","18 Dic","01 Ene","17 Ene", "02 Feb","18 Feb",
                        "06 Mar", "22 Mar", "07 Abr", "23 Abr","09 May","25 May",
                        "10 Jun", "26 Jun","12 Jul", "28 Jul", "13 Ago")

  # Crea una paleta de colores para usar en los gráficos
  
  colores<-c("chocolate1","chartreuse1","cadetblue2","brown3","darkgoldenrod1","darkgreen",
    "blue1","azure3","aquamarine2","deeppink","seagreen3","darkochild2","darkorange1","
    springgreen2","dodgerblue","turquoise2","green2","magenta1","coral4","firebrick2",
    "skyblue1","slategray4","navy","black" )  

  #gráfico de líneas, hay que indicar qué filas se quieren graficar en "-c(n,n,n,n,n)"
  png(nombre_figura_diario, width = 800, height = 450)
  par(xpd = T, mar = par()$mar + c(3,0,-3,0)) #permite modificar las dimensiones del gráfico, dando más espacio en las 4 direcciones
  par(mgp=c(3,1,0))


  matplot(clases_grafico_diario,
          ylab=y_eje_diario_nombre,
          ylim=c(y_min_diario,y_max_diario),
          xlim=c(2,24),
          type="b",
          xaxt="n",
          col=colores,
          lty=3,
          pch="°",
          cex=1.5,
          lwd=3)
  axis(1, at=2:24,
       labels=año_hidrologico,
       cex.axis=0.8,
       las=2)

  # Leyenda del gráfico
  legend("bottom",
         legend=clases_leyenda_diario,
         cex=0.8,
         fill=colores,
         adj=0,
         ncol=2,
         inset=-0.35) # la separación que tiene la leyende a partir del eje x

  # Título del gráfico
  title(titulo_grafico_diario,
        line=0.3,
        adj=1)
  
  
  par(mar=c(5, 4, 4, 2) + 0.1)
  dev.off()
}




# NDVI PROMEDIO ANUAL 201x-201x #

#Nombre de la Figura
nombre_figura_anual="NDVI_prom_anual_1.png"

# Escribir las clases que se quieren graficar ; las clases de leyenda
clases_grafico_anual=t(`SJQ 2012 - 2016`[c(9,10,11,12,13,14,15,16),])
clases_leyenda_anual=`SJQ 2012 - 2016`[c(9,10,11,12,13,14,15,16),1]

# Función del grafico #
ndvi_anual_average_graph<-function(nombre_figura_anual,clases_grafico_anual,clases_leyenda_anual){

  # Se crea una lista de archivos para saber el numero de años
  lista_archivos<-list.files(ubicacion,pattern=glob2rx("consulta*.dbf"))
  
  
  
  # Se definen lo lìmites del eje y
  y_min_anual=min(as.numeric(unlist(clases_grafico_anual)),na.rm=TRUE)
  y_max_anual=max(as.numeric(unlist(clases_grafico_anual)),na.rm=TRUE)
  y_eje_anual_nombre="NDVI"


  # Etiquetas del eje x, años hidrológicos graficados
  año_grafico= año
  año_periodo_anual<-c()
  for(contador in 1:length(lista_archivos)){
    periodo_grafico=paste(año+contador-1,"-",año+contador,sep="")
    año_periodo_anual<-c(año_periodo_anual,periodo_grafico)
  }


  # Crea una paleta de colores para usar en los gráficos
  
  colores<-c("chocolate1","chartreuse1","cadetblue2","brown3","darkgoldenrod1","darkgreen",
             "blue1","azure3","aquamarine2","deeppink","seagreen3","darkochild2","darkorange1","
             springgreen2","dodgerblue","turquoise2","green2","magenta1","coral4","firebrick2",
             "skyblue1","slategray4","navy","black" )  

  #gráfico de líneas, hay que indicar qué filas se quieren graficar en "-c(n,n,n,n,n)"
  png(nombre_figura_anual, width = 800, height = 400)
  par(xpd = T, mar = par()$mar + c(3,0,-3,0)) #permite modificar las dimensiones del gráfico, dando más espacio en las 4 direcciones
  par(mgp=c(3,1,0))

  matplot(clases_grafico_anual,
          ylab=y_eje_anual_nombre,
          ylim=c(y_min_anual,y_max_anual),
          xlim=c(2,length(año_periodo_anual)+1),
          type="b",
          xaxt="n",
          col=colores,
          lty=3,
          pch="°",
          cex=1.5,
          lwd=3)
  axis(1, at=2:(length(año_periodo_anual)+1), 
       labels=año_periodo_anual,
       cex.axis=0.8,
       las=1)
  legend("bottom",
         legend=clases_leyenda_anual,
         cex=0.8,
         fill=colores,
         adj=0,
         ncol=2,
         inset=-0.35) # la separación que tiene la leyende a partir del eje x
  
  par(mar=c(5, 4, 4, 2) + 0.1)
   
  dev.off()

}


("FIN CODIGO")





















