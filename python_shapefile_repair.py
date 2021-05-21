######################
### carga de ArcPy ###
######################
import archook
archook.locate_arcgis()
archook.get_arcpy()
import arcpy
from arcpy.sa import *
arcpy.SignInToPortal_server("pabloav","8dimarno8", "")

# Otras librerias necesarias
import shapefile
import glob
import os


########################################
### Selección de carpetas y archivos ###
########################################
# carpeta con los archivos a modificar
carpeta_origen="C://Pablo QGIS//La Emilia//Shapes//utm 21 norte nad83"

# carpeta donde se guardan los nuevos archivos
carpeta_destino="C://Users//Pablo//Desktop//restauracion"

#################
### Funciones ###
#################
# arregla archivo shapefile corrupto

def shapefile_witer(carpeta_origen,carpeta_destino):

    # define el directorio que se usa
    os.chdir(carpeta_origen)

    # lista con todos los archivos de la carpeta_origen
    lista_archivos_shp=glob.glob("*.shp")
    lista_archivos_dbf=glob.glob("*.dbf")

    # separador utilizado en el ciclo For
    sep=""

    for i in range (0,len(lista_archivos_shp)):
        os.chdir(carpeta_origen)
        nombre_archivo_shp=os.path.splitext(lista_archivos_shp[i])
        nombre_archivo_dbf=os.path.splitext(lista_archivos_dbf[i])
   
    
        # Explicitly name the shp and dbf file objects
        # so pyshp ignores the missing/corrupt shx
   
        nombre_shape=sep.join(nombre_archivo_shp)
        myshp = open(nombre_shape, "rb")
    

        nombre_dbf=sep.join(nombre_archivo_dbf)
        mydbf = open(nombre_dbf, "rb")

        r = shapefile.Reader(shp=myshp, shx=None, dbf=mydbf)
        w = shapefile.Writer(r.shapeType)

        # Copy everything from reader object to writer object   
        w._shapes = r.shapes()
        w.records = r.records()
        w.fields = list(r.fields)
    
        # saving will generate the shx
        os.chdir(carpeta_destino)
        w.save(nombre_archivo_shp[0])

        print("-------- Shapefile terminado --------")
    