import sqlalchemy
from sqlalchemy import create_engine

engine = create_engine('mssql://sa:brent@JoTestDB')

from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey
metadata = MetaData()
users_table = Table('users', metadata,
     Column('id', Integer, primary_key=True),
     Column('name', String(50)),
     Column('fullname', String(50)),
     Column('password', String(50))
)
metadata.create_all(engine)

class User(object):
	def __init__(self, name, fullname, password):
    	self.name = name
		self.fullname = fullname
		self.password = password
    
	def __repr__(self):
		return "<User('%s','%s', '%s')>" % (self.name, self.fullname, self.password)

from sqlalchemy.orm import mapper
mapper(User, users_table) 
ed_user = User('ed', 'Ed Jones', 'edspassword')

from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True)
    name = Column(String(50))
    fullname = Column(String(50))
    password = Column(String(50))
    
    def __init__(self, name, fullname, password):
        self.name = name
        self.fullname = fullname
        self.password = password
        
   def __repr__(self):
        return "<User('%s','%s', '%s')>" % (self.name, self.fullname, self.password)
   
users_table = User.__table__
metadata = Base.metadata

from sqlalchemy.orm import sessionmaker

Session = sessionmaker(bind=engine)

## or

Session = sessionmaker()
Session.configure(bind=engine)

## then 
 
session = Session()

ed_user = User('ed', 'Ed Jones', 'edspassword')
brent_user = User('brent', 'Brent White', 'soulman')
jeff_user = User('jeff', 'Jeff Knaus', 'jeffspassword')
jerry_user = User('jerry', 'Jerry Archer', 'jerryspassword')

session.add(ed_user)
session.add(brent_user)
session.add(jeff_user)
session.add(jerry_user)

our_user = session.query(User).filter_by(name='ed').first() 

engine = create_engine('mssql://sa:brent@JoTestDB')

# using transactions

Session = sessionmaker(autocommit=True)
session = Session()
session.begin()
try:
    item1 = session.query(Item).get(1)
    item2 = session.query(Item).get(2)
    item1.foo = 'bar'
    item2.bar = 'foo'
    session.commit()
except:
    session.rollback()
    raise
