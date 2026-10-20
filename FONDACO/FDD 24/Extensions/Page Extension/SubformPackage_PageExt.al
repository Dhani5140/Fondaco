pageextension 50105 "Sales Order Subform Pkg Ext" extends "Sales Order Subform"
{
    layout
    {
        addafter("No.")
        {
            field("Item Category Options"; Rec."Item Category Options") { ApplicationArea = All; Editable = false; }
            field("Package No."; Rec."Package No.") { ApplicationArea = All; Editable = false; }
            field("Package Line No."; Rec."Package Line No.") { ApplicationArea = All; Editable = false; }
            field("Paket Category Code"; Rec."Paket Category Code") { ApplicationArea = All; Editable = false; }
        }
        modify("No.")
        {
            Editable = not NoLocked;
        }
        modify("Unit of Measure Code")
        {
            Editable = not UoMLocked;
        }
    }

    actions
    {
        addlast(Processing)
        {
            group(PackageActions)
            {
                Caption = 'Contract';

                action(SplitPackageLine)
                {
                    Caption = 'Split Line';
                    ApplicationArea = All;
                    ToolTip = 'Splits this contract line so different items can be delivered.';

                    trigger OnAction()
                    var
                        OrderMgt: Codeunit "Sales Contract Order Mgt.";
                    begin
                        OrderMgt.SplitLine(Rec);
                        CurrPage.Update(false);
                    end;
                }
                action(SelectPackageItem)
                {
                    Caption = 'Select Item';
                    ApplicationArea = All;
                    ToolTip = 'Selects an item from the contract line''s Item Category Options.';

                    trigger OnAction()
                    var
                        OrderMgt: Codeunit "Sales Contract Order Mgt.";
                    begin
                        OrderMgt.SelectItemForLine(Rec);
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    var
        NoLocked: Boolean;
        UoMLocked: Boolean;

    trigger OnAfterGetCurrRecord()
    var
        OrderMgt: Codeunit "Sales Contract Order Mgt.";
    begin
        OrderMgt.GetLineEditability(Rec, NoLocked, UoMLocked);
    end;
}