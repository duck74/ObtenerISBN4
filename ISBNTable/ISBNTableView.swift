//
//  ISBNTableView.swift
//  ISBNTable
//
//  Created by Koss on 29/02/16.
//  Copyright © 2016 mine. All rights reserved.
//

import UIKit
import CoreData

struct Libro {
    var isbn: String
    var titulo: String
    var autor: String
    //var portada: String
    var portadaImagenURL: String
    init(isbn: String, titulo:String, autor: String, portadaImagenURL: String){
        self.isbn = isbn
        self.titulo = titulo
        self.autor = autor
        //self.portada = portada
        self.portadaImagenURL = portadaImagenURL
    }
    
}


class ISBNTableView: UITableViewController {

    var recISBN:String?
    var resultado:[NSString] = [NSString]()
    var portadaImageURL: String = ""
    var libros = [Libro]()
    //var titulos: [String] = [String]()
    var error = false
    var contexto: NSManagedObjectContext? = nil
    var error2: NSError?
    var libroData = [NSManagedObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.contexto = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        
        //let libroEntidad = NSEntityDescription.entityForName("Libro", inManagedObjectContext: self.contexto!)
        let isbnEntidad = NSEntityDescription.entityForName("NumeroISBN", inManagedObjectContext: self.contexto!)
        //let peticion = libroEntidad?.managedObjectModel.fetchRequestTemplateForName("fetchLibro")
        let isbnPeticion = isbnEntidad?.managedObjectModel.fetchRequestTemplateForName("fetchAllISBN")
        print("ViewDidLoad", isbnPeticion)
        do {
            let isbnEntidad = try self.contexto?.executeFetchRequest(isbnPeticion!)
            for isbn in isbnEntidad! {
                let libroISBN = isbn.valueForKey("numero") as! String
                print(libroISBN)
                let libroEnt = isbn.valueForKey("hayLibro") as! NSObject
                let titulo = libroEnt.valueForKey("titulo") as! String
                let autor = libroEnt.valueForKey("autor") as! String
                let portadaURL = libroEnt.valueForKey("portadaTexto") as! String
                self.libros.append(Libro(isbn: libroISBN, titulo: titulo, autor: autor, portadaImagenURL: portadaURL))
            }
            
        }
        catch { }

        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if error {
            showAlert()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       print(self.libros.count)
        return self.libros.count
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Celda", forIndexPath: indexPath)

        // Configure the cell...
        
        cell.textLabel?.text = libros[indexPath.row].titulo
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "NumeroISBN")
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            libroData = results as! [NSManagedObject]
            //print(imageData)
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        if editingStyle == .Delete {
            let itemToDelete = libroData[indexPath.row]
            // Delete the row from the data source and context
            managedContext.deleteObject(itemToDelete)
            libros.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            do {
                //after making changes, save has to be called
                try managedContext.save()
            } catch {
                fatalError("couldn't save context")
            }
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "libroDetalles" {
        let verDetalles = segue.destinationViewController as! VerDetalles
        let selLibro = self.tableView.indexPathForSelectedRow
        print(selLibro)
        verDetalles.libroTitulo = self.libros[selLibro!.row].titulo
        
        //let isbn = NSMutableString(string: recISBN!)
        //verDetalles.isbn = (crearISBNString(isbn))
        verDetalles.isbn = self.libros[selLibro!.row].isbn
        verDetalles.autor = self.libros[selLibro!.row].autor
        verDetalles.portada = self.libros[selLibro!.row].portadaImagenURL
        }
    }
    
    
    @IBAction func entrarISBNView(segue: UIStoryboardSegue) {
        let isbn:NSMutableString?
        let isbnString:String?
        if let isbnViewController = segue.sourceViewController as? EntrarISBN {
            recISBN = isbnViewController.ISBNbuscar
            isbn = NSMutableString(string: recISBN!)
            isbnString = (crearISBNString(isbn!))
            print(isbnString)
            let isbnEntidad = NSEntityDescription.entityForName("NumeroISBN", inManagedObjectContext: self.contexto!)
            let peticion = isbnEntidad?.managedObjectModel.fetchRequestFromTemplateWithName("fetchISBN", substitutionVariables: ["nombre": isbnString!] )
            do {
                print(peticion)
                let seccionEntidad2 = try self.contexto?.executeFetchRequest(peticion!)
                //if the same search has been done before, jump out of the whole function (this is was the empty return does)
                if seccionEntidad2?.count > 0 {
                    
                    return
                }
            }
            catch {}

            //let isbn = NSMutableString(string: isbnViewController.ISBNbuscar!)
            //let isbnString = (crearISBNString(isbn))
           // verISBN.text = isbnString
            //verISBN.text = isbnViewController.ISBNbuscar
            recISBN = isbnViewController.ISBNbuscar
            //verResultado.text = String(recibirJSON())
            //acceder los avlores de JSON
            resultado = recibirJSON()
            }
            if resultado.count < 4 {
                error = true
            }
            else {
            let libro = Libro(isbn: resultado[0] as String, titulo: resultado[1] as String, autor: resultado[2] as String, portadaImagenURL: resultado[3] as String)
               
                libros.insert(libro, atIndex: 0)
                let nuevoISBN = NSEntityDescription.insertNewObjectForEntityForName("NumeroISBN", inManagedObjectContext: self.contexto!)
                
                nuevoISBN.setValue(libro.isbn, forKey: "numero")
                
                let nuevoLibro = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
                nuevoLibro.setValue(libro.titulo, forKey: "titulo")
                nuevoLibro.setValue(libro.autor, forKey: "autor")
                if libro.portadaImagenURL == "Libro no hay una portada" {
                    nuevoLibro.setValue(libro.portadaImagenURL, forKey: "portadaTexto")
                    nuevoLibro.setValue(nil, forKey: "portada")
                    
                }
                else {
                    //creaPortadaEntidad(libro.portadaImagenURL)
                    nuevoLibro.setValue(libro.portadaImagenURL, forKey: "portadaTexto")
                }
                error = false
                nuevoISBN.setValue(nuevoLibro, forKey: "hayLibro")
                print(nuevoLibro)
                print(nuevoISBN)
            
            }
            //guardar los datos
            do {
                
                print(self.contexto!)
                try self.contexto!.save()
                }
            catch {}
            self.tableView!.reloadData()
        
    }

    @IBAction func showAlert() {
        let alertController = UIAlertController(title: "Error", message: resultado[0] as String, preferredStyle: .Alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alertController.addAction(defaultAction)
        
        self.view.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func recibirJSON() -> [NSString]{
        let isbn = NSMutableString(string: recISBN!)
        let isbnString = (crearISBNString(isbn))
        //cuando puede test, usa este variable
        //let x = "978-84-376-0494-7"
        //let y = "978-08-125-0356-2"
        var test:NSString?
        var textField:[NSString] = []
        
        let urlPath:String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
        guard let endpoint = NSURL(string: urlPath as String + isbnString) else { print("Error creating endpoint");return ["error"]}
        print(endpoint)
        let datos:NSData? = NSData(contentsOfURL: endpoint)
        //test = NSString(data: datos!, encoding: NSUTF8StringEncoding)
        if datos?.length > 2 {
            
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(datos!, options: NSJSONReadingOptions.MutableLeaves)
                let dico1 = json as! NSDictionary
                
                let dico2 = dico1["ISBN:"+isbnString] as! NSDictionary
                textField.append(isbnString)
                textField.append(String(dico2["title"]!))
                textField.append(String((dico2["authors"]![0]!["name"]!)!))
                //textField = (textField as String) + "Titulo: " + String(dico2["title"]!) + "\n" + "Autor(es): " + String((dico2["authors"]![0]!["name"]!)!) + "\n"
                
                //libros. = String(dico2["title"]!) //.append(String(dico2["title"]!))
                //print(titulos)
                if dico2["cover"] == nil {
                    textField.append("Libro no hay una portada")
                    //textField =  (textField as String) + "\nLibro no hay una portada"
                    //portadaTitulo.hidden = true
                    //portadaView.image = nil
                }
                else
                {
                    let url = String((dico2["cover"]!["medium"]!)!)
                        //portadaImage = UIImage(data: data)
                        textField.append(String(url))
                        print(url)
                        //portadaTitulo.hidden = false
                        //self.portadaView.image = portadaImage
                    
                    //textField.append("Portada")
                    //textField = (textField as String) //+ "\nPortada" + String((dico2["cover"]!["medium"]!)!)
                }
                
            }
            catch _ {
                
            }
        }
        else
        {
            print(test)
            test = "error"
        }
        
        if  (datos == nil){
            return ["Hay un problema con los datos o el coneccion."]
        }
        else if test == "error" {
            return ["No encontró un libro con este ISBN"]
        }
        else {
            return textField
        }
    }
    
    func creaPortadaEntidad(url: String) -> NSObject{
        print(url)
        let img_url = NSURL(string: url)
        let data = NSData(contentsOfURL: img_url!)
        let imagen = UIImage(data: data!)
        

        var entidadPortada = NSObject()
        entidadPortada = NSEntityDescription.insertNewObjectForEntityForName("Libro", inManagedObjectContext: self.contexto!)
        entidadPortada.setValue(UIImageJPEGRepresentation(imagen!, 1.0), forKey: "portada")
        
        
        return entidadPortada
        
    }
    
    func crearISBNString(isbn: NSMutableString) -> String{
        isbn.insertString("-", atIndex: 3)
        isbn.insertString("-", atIndex: 6)
        isbn.insertString("-", atIndex: 10)
        isbn.insertString("-", atIndex: 15)
        //print(isbn)
        return String(isbn)
    }

}
