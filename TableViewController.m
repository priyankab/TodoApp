//
//  TableViewController.m
//  ToDoApp
//
//  Created by Priyanka Bhalerao on 1/18/14.
//  Copyright (c) 2014 iOSClass. All rights reserved.
//

#import "TableViewController.h"
#import "CustomCell.h"
#import <objc/runtime.h>
static char indexPathKey;
BOOL addClicked;

@interface TableViewController ()

@property (nonatomic,strong) NSMutableArray *todoItems;
@property (nonatomic,strong) NSString *todoFileName;
@property (nonatomic,strong) UIBarButtonItem *textDoneButton;
@property (nonatomic,strong) UIBarButtonItem *editButton;
@property (nonatomic,strong) UIBarButtonItem *addButton;
@property (nonatomic,strong) UIBarButtonItem *textCancelButton;


- (void) onAddButton;


@end

@implementation TableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSArray *filepaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [filepaths objectAtIndex:0];
        self.todoFileName = [documentsDirectory stringByAppendingPathComponent:@"todos.txt"];
        NSLog (@"The filepath is :%@",self.todoFileName);
        self.todoItems  = [[NSMutableArray alloc] initWithContentsOfFile:self.todoFileName];
        NSLog ( @"Size is %u", self.todoItems.count);
        if(self.todoItems == nil){
            self.todoItems = [[NSMutableArray alloc]init];
            NSLog (@"Its actually NIL");
        }
        
        //Initialize all button properties
        self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target: self action: @selector(onAddButton)];
        addClicked = NO;
        
       
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Add navigation bar
    self.navigationItem.title = @"To Do List";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = self.addButton;
    
    //Register xib file
    
    UINib *customNib = [UINib nibWithNibName:@"CustomCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"CustomCell"];
    
  
}
-(void) viewDidDisappear:(BOOL)animated
{
    /*NSLog ( @"Size is %u", self.todoItems.count);
     NSLog (@"File name is %@",self.todoFileName);*/
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing  animated:animated] ;
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.todoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CustomCell";
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.todoText.delegate = self;
    objc_setAssociatedObject(cell.todoText,&indexPathKey , indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSString *celltext = [self.todoItems objectAtIndex:indexPath.row];
    cell.todoText.text = celltext;
    
    // Configure the cell...
    [self.todoItems writeToFile:self.todoFileName atomically:YES];
    return cell;
}

- (void) onAddButton{
    
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
    NSString *sampletext = @"";
    [self.todoItems insertObject:sampletext atIndex:0];
   
    [self.tableView reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *tablecell =  [self.tableView cellForRowAtIndexPath:indexPath];
    CustomCell *cell = (CustomCell *)tablecell;
    addClicked = YES;
    [cell.todoText becomeFirstResponder];
    
    
    
}

- (void) onEditButton{
    
}
                                



#pragma mark - UITextField Delegate methods


- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField   {
    NSIndexPath *indexPath = objc_getAssociatedObject(textField, &indexPathKey);
    if(self.tableView.editing ){
        return YES;
    }else if (addClicked && indexPath.row == 0){
        return YES;
    }else{
        return NO;
    }
}
-(BOOL) textFieldShouldEndEditing:(UITextField *)textField{
    
    if(addClicked == YES){
        addClicked = NO;
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    
    NSIndexPath *indexPath = objc_getAssociatedObject(textField, &indexPathKey);
    [self.todoItems replaceObjectAtIndex:indexPath.row withObject:textField.text] ;
    [self.todoItems writeToFile:self.todoFileName atomically:YES];
    [self.tableView reloadData];
    [textField resignFirstResponder];
    return YES;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.todoItems removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.todoItems writeToFile:self.todoFileName atomically:YES];
    }  /*
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   */
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(self.tableView.editing){
        UITableViewCell *fromtablecell =  [self.tableView cellForRowAtIndexPath:fromIndexPath];
        CustomCell *fromcell = (CustomCell *)fromtablecell;
        NSString* temp = fromcell.todoText.text;
        
        UITableViewCell *totablecell =  [self.tableView cellForRowAtIndexPath:toIndexPath];
        CustomCell *tocell = (CustomCell *)totablecell;
        NSString* totext = tocell.todoText.text;
        
        [self.todoItems replaceObjectAtIndex:fromIndexPath.row withObject:totext];
        [self.tableView reloadData];
        [self.todoItems replaceObjectAtIndex:toIndexPath.row withObject:temp];
        [self.tableView reloadData];
        [self.todoItems writeToFile:self.todoFileName atomically:YES];
        
    }
    
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
