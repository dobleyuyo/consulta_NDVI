######################
### carga de ArcPy ###
######################
import archook
archook.locate_arcgis()
archook.get_arcpy()
import arcpy
from arcpy.sa import *
arcpy.SignInToPortal_server("pabloav","8dimarno8", "")
arcpy.CheckOutExtension('Spatial') 


########################################
### Selección de carpetas y archivos ###
########################################

# Directorio de Trabajo ###
directorio_trabajo="C:\\Pablo QGIS\\ADECO\\campos\\imagenes\\H12V12\\TIF\\2012-2013"

# Carpeta de guardado ###
carpeta_guardado ="C:\\Pablo QGIS\\ADECO\\campos\\imagenes\\H12V12\\raster escalado\\2012-2013"

#########################
### Datos importantes ###
#########################

# Año hidrológico ###
fecha = 2012

# Locación
cuadrante = "H12V12"


# calcula un nuevo raster en base a la confiabilidad de los datos de cada pixel.
def raster_multiplitacion_hidrologic(directorio_trabajo,carpeta_guardado,fecha,cuadrante):
  
    arcpy.env.workspace= directorio_trabajo

    # Crea la lista de todos los Rasters del directorio
    lista_rasters = arcpy.ListRasters('*.tif*')
    
    # ciclo for de multiplicacion y guardado de rasters
    contador_ndvi= 0
    contador_archivo = 1
    dia = 241
    ext_archivo=".tif"

    for contador_ndvi in range(0,len(lista_rasters)-1,2):  
        # Nombre archvio
        if dia > 365:
           dia=001
           fecha+=1

        datos_archivo = [str(contador_archivo),str(fecha),str(dia),"NDVI",cuadrante,"Pixel_reliablilty_decimal",ext_archivo]
        sep= "_"
        nombre_archivo=sep.join(datos_archivo)
        datos_archivo_2=[carpeta_guardado,"\\",nombre_archivo]
        sep_2=""
        archivo_completo=sep_2.join(datos_archivo_2)
    
        # Multiplicacion de los rasters y guardado
        NDVI = Raster(lista_rasters[contador_ndvi])
        pixel_reliability = Raster(lista_rasters[contador_ndvi + 1])
        outRaster =(Con((pixel_reliability == 0),NDVI*0.0001,0))
        outRaster.save(archivo_completo)

        # Actualizacion dia Juliano
        dia+=16
        contador_archivo+=1

    print('-------- Todos los rasters fueron trabajados --------')
  







