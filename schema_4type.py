class User(BaseModel):
    fullname: str
    username: str
    pwd: str
    created: Optional[datetime] = None
    urole: RoleEnum = RoleEnum.guest
    status: StatusEnum = StatusEnum.active
    phonenumber: Optional[str] = None
    picture: Optional[str] = None  # URL or path
    region: Optional[str] = None
    street: Optional[str] = None
    levelofeducation: LevelOfEducationEnum = LevelOfEducationEnum.none
    income: IncomeEnum = IncomeEnum.below_1000
    email: str
    disability: Optional[str] = None  # Optional field for disability information
    class Config:
        from_attributes = True

  class Skill(BaseModel):
    skill_name: str
    skill_level: SkillEnum = SkillEnum.beginer
    comments: Optional[str] = None
    user_id: int  # Foreign key reference to the user
    class Config:
        from_attributes = True

class Work(BaseModel):
    work_title: str
    work_type: WorkEnum= WorkEnum.parttime
    work_description: Optional[str] = None
    work_experience: WorkExperience= WorkExperience.beginer  
    user_id: int  # Foreign key reference to the user
    class Config:
        from_attributes = True

class Product(BaseModel):
    product_name: str
    description: Optional[str] = None
    price: float 
    image: Optional[str] = None  # URL or path
    comments: Optional[str] = None
    # product_id: int  
    user_id: int  # Foreign key reference to the user
    class Config:
        from_attributes = True
