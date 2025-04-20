class RoleEnum(str, Enum):
    admin = "admin"
    guest = "guest"
    supporter = "supporter"
class StatusEnum(str, Enum):
    active = "active"
    suspended = "suspended"
    pending = "pending"
    disabled = "disabled"
class LevelOfEducationEnum(str, Enum):
    primary = "primary"
    secondary = "secondary"
    degree = "degree"
    postgraduate = "postgraduate"
    none = "none"  # For users with no formal education
class IncomeEnum(str, Enum):
    below_1000 = "below_1000_tsh"
    below_10000 = "below_10000_tsh"
    below_30000 = "below_30000_tsh"
# User model
class UserDB(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    fullname = Column(String, nullable=False)
    username = Column(String, unique=True, nullable=False)
    password = Column(String, nullable=False)
    createdDate = Column(DateTime, default=datetime.utcnow)
    role = Column(String, nullable=False,default=RoleEnum.guest.value)
    status = Column(String, nullable=False,default=StatusEnum.active.value)
    phonenumber = Column(String, nullable=True)
    profilePicture = Column(Text, nullable=True)  # Use Text for larger image data or a URL
    region = Column(String, nullable=True)
    street = Column(String, nullable=True)
    levelOfEducation = Column(String, nullable=False, default=LevelOfEducationEnum.none.value)
    income = Column(String, nullable=False, default=IncomeEnum.below_1000.value)
    email = Column(String, unique=True, nullable=False)
    disability = Column(String, nullable=True)  # Optional field for disability information

    # Relationships
    skills = relationship("SkillDB", back_populates="user")
    works = relationship("WorkDB", back_populates="user")
    products = relationship("ProductDB", back_populates="user")





class SkillEnum(str, Enum):
    beginer = "beginer"
    intermidiate = "intermidiate"
    advanced = "advanced"
    expert = "expert"
# Skill model
class SkillDB(Base):
    __tablename__ = "skills"
    id = Column(Integer, primary_key=True, index=True)
    skill_name = Column(String, nullable=False)
    skill_level = Column(String, nullable=False, default=SkillEnum.beginer.value)
    # skill_level = Column(Enum(SkillEnum), nullable=False, default=SkillEnum.beginer.value)
    comments = Column(Text, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("UserDB", back_populates="skills")

# Work model
class WorkEnum(str, Enum):
    parttime = "parttime"
    fulltime = "fulltime"
    freelance = "freelance"
   
class WorkExperience(str, Enum):
    beginer = "beginer"
    intermidiate = "intermidiate"
    advanced = "advanced"
class WorkDB(Base):
    __tablename__ = "works"
    id = Column(Integer, primary_key=True, index=True)
    work_title = Column(String, nullable=False)
    work_description = Column(Text, nullable=False)
    work_type = Column(String, nullable=False, default=WorkEnum.parttime.value)
    work_experience = Column(String, nullable=False, default=WorkExperience.beginer.value)
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("UserDB", back_populates="works")


# Product model
class ProductDB(Base):
    __tablename__ = "products"
    id = Column(Integer, primary_key=True, index=True)
    productName = Column(String, nullable=False)
    description = Column(Text, nullable=False)
    price = Column(Float, nullable=False)
    image = Column(Text, nullable=True)
    comments = Column(Text, nullable=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("UserDB", back_populates="products")



